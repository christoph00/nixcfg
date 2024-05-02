{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.services.blocky;
in
{
  options.chr.services.blocky = with types; {
    enable = mkBoolOpt false "Enable blocky DNS Server.";
  };
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        53
        5335
      ];
      allowedUDPPorts = [
        53
        5335
      ];
    };

    environment.systemPackages = with pkgs; [ blocky ];

    services = {
      resolved.enable = lib.mkForce false;

      blocky = {
        enable = true;
        settings = {
          upstreams = {
            groups = {
              default = [
                "tcp-tls:fdns1.dismail.de:853"
                "tcp-tls:recursor01.dns.lightningwirelabs.com:853"
                "https://one.one.one.one/dns-query"
                "https://dns10.quad9.net/dns-query"
                "https://dns-unfiltered.adguard.com/dns-query"
                "https://dns.telekom.de/dns-query"
              ];
            };
            timeout = "10s";
          };
          blocking = {
            blackLists.default = [ "https://v.firebog.net/hosts/Easyprivacy.txt" ];
            clientGroupsBlock.default = [ "default" ];
          };
          caching = {
            prefetching = true;
            prefetchExpires = "2h";
            prefetchThreshold = 5;
            minTime = "2h";
            maxTime = "12h";
            maxItemsCount = 0;
            cacheTimeNegative = "2m";
          };
          prometheus = {
            enable = true;
            path = "/metrics";
          };
          ports.http = 4040;
          ports.dns = "127.0.0.1:53,[::1]:53,192.168.2.194:53";

          bootstrapDns = [
            "tcp+udp:1.1.1.1"
            "https://1.1.1.1/dns-query"
          ];
          ede.enable = true;
          clientLookup.upstream = "192.168.2.1";
          conditional.mapping = {
            "." = "192.168.2.1";
            "lan.r505.de" = "192.168.2.1";
            "arpa" = "192.168.2.1";
            "2.168.192.in-addr.arpa" = "192.168.2.1";
            "168.192.in-addr.arpa" = "192.168.2.1";
          };
        };
      };

      vmagent.prometheusConfig.scrape_configs = [
        {
          job_name = "blocky";
          static_configs = [
            { targets = [ "localhost:${toString config.services.blocky.settings.ports.http}" ]; }
          ];
        }
      ];
    };
    networking.nameservers = [
      "127.0.0.1"
      ":::"
    ];
    systemd.services.blocky = {
      after = [ "netbird.service" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "1";
      };
    };
    #systemd.services.netbird.after = ["blocky.service"];
  };
}
