# This module is responsible for configuring WireGuard tunnels and peers.
# It uses a central configuration for all WireGuard peers and generates the necessary configuration.
{
  lib,
  flake,
  config,
  ...
}: let
  inherit (lib) types mkOption mkIf attrValues filterAttrs;
  inherit (flake.lib) mkBoolOpt mkStrOpt mkSecret;
  cfg = config.network.wireguard;
  hostname = config.networking.hostName;

  # Helper function to create a WireGuard peer configuration
  mkWgPeer = { name, ip, pubkey, publicIP ? null, port ? 51820, extraAllowedIPs ? [] }: {
    inherit name ip pubkey publicIP port extraAllowedIPs;
    publicKey = pubkey;
    allowedIPs = ["${ip}/32"] ++ extraAllowedIPs;
    endpoint = if publicIP != null && publicIP != "dynamic" then "${publicIP}:${toString port}" else "${name}:${toString port}";
  };

  # Helper function to create automatic peers from flake configurations
  mkAutoPeer = name: {
    ip ? null,
    pubkey ? null,
    port ? 51820,
    extraAllowedIPs ? [],
  }: let
    hostConfig = flake.nixosConfigurations.${name} or (throw "Host ${name} not found in flake.nixosConfigurations");
    wgConfig = hostConfig.config.network.wireguard or {};
    resolvedIP = if ip != null then ip else wgConfig.ip or (throw "No IP configured for ${name}. Make sure ${name}.config.network.wireguard.ip is set.");
    resolvedPubkey = if pubkey != null then pubkey else wgConfig.publicKey or (throw "No public key configured for ${name}. Make sure ${name}.config.network.wireguard.publicKey is set.");
    publicIP = hostConfig.config.network.publicIP or "dynamic";
  in mkWgPeer {
    inherit name;
    ip = resolvedIP;
    pubkey = resolvedPubkey;
    inherit publicIP port extraAllowedIPs;
  };

  # Additional manual peers (e.g., OpenWRT routers, external servers)
  manualPeers = {
    erx = mkWgPeer {
      name = "erx.lan";
      ip = "10.100.100.1";
      pubkey = "jEuJnsFIoWJ1WLyHG6Jih0TFCOupoPmhaMzCv0wBCQY=";
      # publicIP = "ROUTER_PUBLIC_IP";  # Optional: uncomment if router has public IP
    };
  };

  # Filter NixOS hosts that have WireGuard enabled
  wireguardHosts = lib.filterAttrs (name: hostConfig:
    hostConfig.config.network.wireguard.enable or false
  ) flake.nixosConfigurations;

  # Generate automatic peers for all NixOS hosts with WireGuard enabled
  autoPeers = lib.mapAttrs (name: hostConfig: mkAutoPeer name {
    # IP and pubkey should come from hostConfig.network.wireguard
    # These must be configured in each host's configuration
  }) wireguardHosts;

  # Combine automatic and manual peers
  wgnet = autoPeers // manualPeers;

  # Get current host configuration - first try autoPeers, then manualPeers
  currentHost = autoPeers.${hostname} or manualPeers.${hostname} or (throw "Host ${hostname} not found in wgnet configuration");

  # Function to generate peer configurations from wgnet
  # It filters out the current host from the peer list and extracts only the required WireGuard attributes
  # Only sets endpoint if the peer has a public IP (not for dynamic IPs)
  generatePeers = hostName: networkConfig:
    map (peer: {
      publicKey = peer.publicKey;
      allowedIPs = peer.allowedIPs;
    } // (lib.optionalAttrs (peer.publicIP != null && peer.publicIP != "dynamic") {
      endpoint = peer.endpoint;
    })) (attrValues (filterAttrs (name: _: name != hostName) networkConfig));

  in {
  # Define the options for this module
  options.network.wireguard = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the private WireGuard network.";
    };
    ip = mkOption {
      type = types.str;
      description = "The IP address of the host in the WireGuard network.";
    };
    publicKey = mkOption {
      type = types.str;
      description = "The public key for the WireGuard interface.";
    };
    };

  # Configure the system based on the provided options
  config = mkIf cfg.enable {
    # Create secret for private key using agenix
    age.secrets."wg-${hostname}" = mkSecret {
      file = "wg-${hostname}";
      owner = "root";
      group = "systemd-network";
      mode = "640";
    };

    networking.wireguard.interfaces.wg0 = {
      # The IP address of the host's WireGuard interface from this host's config
      ips = ["${cfg.ip}/24"];
      # The path to the private key file from agenix secrets
      privateKeyFile = config.age.secrets."wg-${hostname}".path;
      # The port to listen on
      listenPort = 51820;
      # Generate the peer configurations from all other WireGuard hosts
      peers = generatePeers hostname wgnet;
    };

    # Open the WireGuard port in the firewall
    networking.firewall.allowedUDPPorts = [51820];

    # Optional: Add entries to /etc/hosts for hostname resolution
    networking.extraHosts = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: hostCfg: "${hostCfg.ip} ${name}") wgnet
    );

    };
}
