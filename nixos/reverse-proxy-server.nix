{
  pkgs,
  config,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [9090 8082 443 80];

  age.secrets.traefik = {
    file = ../secrets/traefik.env;
    owner = config.systemd.services.traefik.serviceConfig.User;
    mode = "0440";
  };

  systemd.services.traefik.serviceConfig.EnvironmentFile = config.age.secrets.traefik.path;
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      api = {dashboard = true;};
      entryPoints = {
        http = {address = ":80";};
        https = {address = ":443";};
        api = {address = ":9090";};
        metrics = {address = ":8082";};
      };
      certificatesResolvers.cloudflare.acme = {
        email = "christoph@asche.co";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
        };
      };
      accessLog = {};
      metrics = {
        prometheus = {
          addEntryPointsLabels = true;
          entryPoint = "metrics";
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        serversTransports = {unsafe_tls = {insecureSkipVerify = true;};};
        routers = {
          traefik = {
            entryPoints = ["api"];
            rule = "Host(`${config.networking.hostName}.dash.net.r505.de`)";
            service = "api@internal";
          };
          home-assistant = {
            rule = "Host(`ha.r505.de`) || host(`ha2.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "home-assistant";
          };
          nas-dav = {
            rule = "Host(`dav.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "nas-dav";
          };
          webmail = {
            rule = "Host(`webmail.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "webmail";
          };
          caldav = {
            rule = "Host(`caldav.net.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "caldav";
          };
          grafana = {
            rule = "Host(`graf.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "grafana";
          };
          jmap = {
            rule = "Host(`jmap.r505.de`)";
            tls = {certResolver = "cloudflare";};
            service = "stalwart-jmap";
          };
        };
        services = {
          home-assistant = {
            loadBalancer = {
              servers = [{url = "http://100.102.159.142:8123";}];
            };
          };
          nas-dav = {
            loadBalancer = {
              servers = [{url = "http://100.102.159.142:8033";}];
            };
          };
          webmail = {
            loadBalancer = {
              servers = [{url = "http://oca.cama-boa.ts.net:8077";}];
            };
          };
          caldav = {
            loadBalancer = {
              servers = [{url = "http://oca.cama-boa.ts.net:5232";}];
            };
          };
          grafana = {
            loadBalancer = {
              servers = [{url = "http://oca.cama-boa.ts.net:2342";}];
            };
          };
          stalwart-jmap = {
            loadBalancer = {
              servers = [{url = "http://100.67.176.239:8055";}];
            };
          };
        };
      };
    };
  };
}
