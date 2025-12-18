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

  mkWgPeer = {
    name,
    ip,
    pubkey,
    publicIP ? null,
    port ? 51820,
    extraAllowedIPs ? [],
  }: {
    inherit name ip pubkey publicIP port extraAllowedIPs;
    publicKey = pubkey;
    allowedIPs = ["${ip}/32"] ++ extraAllowedIPs;
    endpoint =
      if publicIP != null && publicIP != "dynamic"
      then "${publicIP}:${toString port}"
      else "${name}:${toString port}";
  };

  mkAutoPeer = name: {
    ip ? null,
    pubkey ? null,
    port ? 51820,
    extraAllowedIPs ? [],
  }: let
    hostConfig = flake.nixosConfigurations.${name} or (throw "Host ${name} not found in flake.nixosConfigurations");
    wgConfig = hostConfig.config.network.wireguard or {};
    resolvedIP =
      if ip != null
      then ip
      else wgConfig.ip or (throw "No IP configured for ${name}. Make sure ${name}.config.network.wireguard.ip is set.");
    resolvedPubkey =
      if pubkey != null
      then pubkey
      else wgConfig.publicKey or (throw "No public key configured for ${name}. Make sure ${name}.config.network.wireguard.publicKey is set.");
    publicIP = hostConfig.config.network.publicIP or "dynamic";
  in
    mkWgPeer {
      inherit name;
      ip = resolvedIP;
      pubkey = resolvedPubkey;
      inherit publicIP port extraAllowedIPs;
    };

  manualPeers = {
    erx = mkWgPeer {
      name = "erx.lan";
      ip = "10.100.100.1";
      pubkey = "jEuJnsFIoWJ1WLyHG6Jih0TFCOupoPmhaMzCv0wBCQY=";
      # publicIP = "ROUTER_PUBLIC_IP";  # Optional
      extraAllowedIPs = ["192.168.2.0/24"];
    };
  };

  wireguardHosts =
    lib.filterAttrs (
      name: hostConfig:
        hostConfig.config.network.wireguard.enable or false
    )
    flake.nixosConfigurations;

  autoPeers = lib.mapAttrs (name: hostConfig:
    mkAutoPeer name {
    })
  wireguardHosts;

  wgnet = autoPeers // manualPeers;

  currentHost = autoPeers.${hostname} or manualPeers.${hostname} or (throw "Host ${hostname} not found in wgnet configuration");

  generatePeers = hostName: networkConfig:
    map (peer:
      {
        publicKey = peer.publicKey;
        allowedIPs = peer.allowedIPs;
      }
      // (lib.optionalAttrs (peer.publicIP != null && peer.publicIP != "dynamic") {
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
    homeRoute = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Route to Home LAN";
    };
  };

  config = mkIf cfg.enable {
    age.secrets."wg-${hostname}" = mkSecret {
      file = "wg-${hostname}";
      owner = "root";
      group = "systemd-network";
      mode = "640";
    };

    networking.firewall.trustedInterfaces = ["wg0"];

    networking.wireguard.interfaces.wg0 = {
      ips = ["${cfg.ip}/24"];
      privateKeyFile = config.age.secrets."wg-${hostname}".path;
      listenPort = 51820;
      peers = generatePeers hostname wgnet;
    };

    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    networking.firewall.allowedUDPPorts = [51820];

    networking.interfaces.wg0.ipv4.routes = mkIf cfg.homeRoute [
      {
        address = "192.168.2.0";
        prefixLength = 24;
        via = "10.100.100.1";
      }
    ];

    networking.extraHosts = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: hostCfg: "${hostCfg.ip} ${name}") wgnet
    );
  };
}
