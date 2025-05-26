{
  options,
  config,
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkStrOpt mkOpt mkBoolOpt;
  cfg = config.network.router;

in
{
  imports = [
    ./lan.nix
    ./wan.nix
    ./firewall.nix
    ./dhcp.nix
    ./dns.nix
  ];
  options.network.router = {
    enable = mkBoolOpt false;
    externalInterface = mkStrOpt "eth0";
    internalInterface = mkStrOpt "eth1";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dnsutils
      dig
      ethtool
      tcpdump
      speedtest-cli

    ];

  };
}
