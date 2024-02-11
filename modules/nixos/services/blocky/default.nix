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
                "https://one.one.one.one/dns-query"
                "https://dns10.quad9.net/dns-query"
                "https://dns-unfiltered.adguard.com/dns-query"
              ];
            };
            timeout = "10s";
          };
          startVerifyUpstream = true;
          blocking = {
            blackLists.default = [
              "https://v.firebog.net/hosts/Easyprivacy.txt"
              "https://v.firebog.net/hosts/Prigent-Ads.txt"
              "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              "https://v.firebog.net/hosts/RPiList-Malware.txt"
              "https://v.firebog.net/hosts/RPiList-Phishing.txt"
              "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
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

          bootstrapDns = "192.168.2.1";
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

      vmagent.prometheusConfig.scrapeConfigs = [
        {
          job_name = "blocky";
          static_configs = [
            {
              targets = ["localhost:${toString config.services.blocky.ports.http}"];
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
