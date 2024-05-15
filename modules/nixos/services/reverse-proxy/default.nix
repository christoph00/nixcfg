{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.reverse-proxy;
in {
  options.chr.services.reverse-proxy = with types; {
    enable = mkBoolOpt' false;
  };
  config = mkIf cfg.enable {
    age.secrets.traefik = {
      file = ../../../../secrets/traefik.env;
      owner = "traefik";
    };
    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [{directory = "/var/lib/traefik";}];
    };
    services.traefik.enable = true;
    systemd.services.traefik.serviceConfig.EnvironmentFile = [config.age.secrets.traefik.path];
    services.traefik.staticConfigOptions = {
      log.level = "INFO";
      certificatesResolvers.cfWildcard.acme = {
        email = "cert@r505.de";
        storage = "/var/lib/traefik/acme.json";
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
        dnsChallenge.provider = "cloudflare";
        dnsChallenge.resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
      };

      entryPoints = {
        http = {
          address = ":80";
          forwardedHeaders.insecure = true;
          http.redirections.entryPoint = {
            to = "https";
            scheme = "https";
          };
        };

        https = {
          address = ":443";
          # enableHTTP3 = true;
          forwardedHeaders.insecure = true;
        };

        test = {
          address = ":1313";
          forwardedHeaders.insecure = true;
        };
      };
    };
  };
}
