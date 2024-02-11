{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.blocky;
in {
  options.chr.services.blocky = with types; {
    enable = mkBoolOpt false "Enable blocky DNS Server.";
  };
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [53 5335];
      allowedUDPPorts = [53 5335];
    };

    environment.systemPackages = with pkgs; [blocky];

    services = {
      resolved.enable = lib.mkForce false;

      blocky = {
        enable = true;
        settings = {
          upstreams = {
            groups = {
              default = [
                "5.9.164.112"
                "9.9.9.9"
                "https://one.one.one.one/dns-query"
                "https://dns10.quad9.net/dns-query"
                "https://dns-unfiltered.adguard.com/dns-query"
              ];
            };
            timeout = "10s";
          };
          blocking = {
            blackLists.default = [
              "https://v.firebog.net/hosts/Easyprivacy.txt"
            ];
            clientGroupsBlock.default = ["default"];
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

          bootstrapDns = ["tcp+udp:1.1.1.1" "https://1.1.1.1/dns-query"];
          ede.enable = true;
          clientLookup.upstream = "192.168.2.1";
          conditional.mapping = {
            "." = "192.168.2.1";
            ".local" = "192.168.2.1";
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
            {
              targets = ["localhost:${toString config.services.blocky.settings.ports.http}"];
            }
          ];
        }
      ];
    };
    systemd.services.blocky = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "1";
      };
    };
  };
}
