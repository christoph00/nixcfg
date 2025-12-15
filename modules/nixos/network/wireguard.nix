# This module is responsible for configuring WireGuard tunnels and peers.
# It automatically discovers peers from all hosts in the flake and configures them on each host.
{
  lib,
  flake,
  config,
  ...
}: let
  inherit (lib) types mkOption mkIf;
  inherit (flake.lib) mkBoolOpt mkStrOpt mkSecret allSystems;
  cfg = config.network.wireguard;

  # Function to generate peer configurations from the list of hosts
  # It filters out the current host from the peer list
  generatePeers = hostName: allHosts:
    lib.mapAttrsToList (name: hostConfig: {
      publicKey = hostConfig.network.wireguard.publicKey;
      allowedIPs = ["${hostConfig.network.wireguard.ip}/32"];
      endpoint = "${hostConfig.network.publicIP}:${toString hostConfig.network.wireguard.port}";
    }) (lib.filterAttrs (name: _: name != hostName) allSystems);
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
    privateKeyFile = mkOption {
      type = types.path;
      description = "Path to the private key for the WireGuard interface.";
    };
    publicKey = mkOption {
      type = types.str;
      description = "The public key for the WireGuard interface.";
    };
    port = mkOption {
      type = types.port;
      default = 51820;
      description = "The port to listen on for WireGuard connections.";
    };
  };

  # Configure the system based on the provided options
  config = mkIf cfg.enable {
    networking.wireguard.interfaces.wg0 = {
      # The IP address of the host's WireGuard interface
      ips = ["${cfg.ip}/24"];
      # The path to the private key file
      privateKeyFile = cfg.privateKeyFile;
      # The port to listen on
      listenPort = cfg.port;
      # Generate the peer configurations
      peers = generatePeers config.networking.hostName config.nixcfg.hosts;
    };

    # Open the WireGuard port in the firewall
    networking.firewall.allowedUDPPorts = [cfg.port];
  };
}
