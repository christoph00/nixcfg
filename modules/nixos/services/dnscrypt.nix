{
  lib,
  config,
  pkgs,
  flake,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.svc.dnscrypt;
in
{
  options.svc.dnscrypt = {
    enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {

    services.dnscrypt-proxy2 = {
      enable = mkDefault true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;

        listen_addresses = [ "127.0.0.1:53" ];

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        forwarding_rules = pkgs.writeText "forwarding-rules.txt" ''
          local            $DHCP
          lan            $DHCP
          192.168.in-addr.arpa $DHCP
        '';
      };
    };

    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];

      dhcpcd.extraConfig = "nohook resolv.conf";
    };

    services.resolved.enable = false;

  };
}
