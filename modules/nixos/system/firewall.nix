{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkForce;
in {
  services = {
    fail2ban = {
      enable = true;
      banaction = "iptables-multiport[blocktype=DROP]";
      maxretry = 7;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
      ];

      bantime-increment = {
        enable = true;
        rndtime = "12m";
        overalljails = true;
        multipliers = "4 8 16 32 64 128 256 512 1024";
        maxtime = "48h";
      };
    };
  };
  networking = {
    nftables.enable = false;
    firewall = {
      enable = mkDefault true;
      package = mkDefault pkgs.iptables-nftables-compat;
      allowedTCPPorts = [
        443
        8080
      ];
      allowedUDPPorts = [];
      allowPing = mkDefault true;
      logReversePathDrops = true;
      logRefusedConnections = mkDefault false;
      checkReversePath = mkForce false; # Don't filter DHCP packets, according to nixops-libvirtd
    };
  };
}
