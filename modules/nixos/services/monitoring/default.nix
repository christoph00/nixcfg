{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.monitoring;
in {
  options.chr.services.monitoring = with types; {
    enable = mkBoolOpt true "Enable monitoring Service.";
  };
  config = mkIf cfg.enable {
    age.secrets.grafana-password = {
      file = ../../../../secrets/grafana-password;
    };
    services.grafana-agent-flow = {
      enable = true;

      enableJournaldLogging = true;

      staticScrapes = {
        hass = mkIf config.chr.services.home-assistant.enable {
          targets = ["localhost:8123"];
          bearerTokenFile = config.sops.secrets.hass_token.path;
          metricsPath = "/api/prometheus";
        };

        jellyfin = mkIf config.chr.services.media.enable {
          targets = ["localhost:8096"];
        };

        cloudflared = mkIf config.services.cloudflared.enable {
          targets = ["localhost:8927"];
        };
      };

      grafanaCloud = {
        enable = true;
        stack = "aco";
        tokenFile = config.age.secrets.grafana-password.path;
      };
    };
  };
}
