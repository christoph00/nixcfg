# https://github.com/hbjydev/dots.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.vmetrics;
in {
  options.chr.services.vmetrics = {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    services.victoriametrics = {
      enable = true;
      listenAddress = ":8428";
      retentionPeriod = 2;
    };
    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [{directory = "/var/lib/private/victoriametrics";}];
    };

    services.traefik.dynamicConfigOptions.http.routers.vmetrics = {
      entryPoints = ["https" "http"];
      rule = "Host(`metrics.internal.r505.de`)";
      service = "vmetrics";
      tls.domains = [{main = "*.r505.de";}];
      tls.certResolver = "cfWildcard";
    };
    services.traefik.dynamicConfigOptions.http.services.vmetrics.loadBalancer = {
      passHostHeader = false;
      servers = [{url = "http://127.0.0.1:8428";}];
    };
  };
}
