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
    scrapeRouter = mkBoolOpt false "Enable scraping router.";
    httpListenAddr = mkOption {
      type = types.str;
      default = "127.0.0.1:9100";
      description = "The address and port that the HTTP server listens on.";
    };
  };
  config = mkIf cfg.enable {
    age.secrets.grafana-password = {
      file = ../../../../secrets/grafana-password;
      owner = "grafana-agent-flow";
      group = "grafana-agent-flow";
    };
    services.grafana-agent-flow = {
      enable = true;

      enableJournaldLogging = true;
      httpListenAddr = cfg.httpListenAddr;

      staticScrapes = {
        # hass = mkIf config.chr.services.home-assistant.enable {
        #   targets = ["localhost:8123"];
        #   bearerTokenFile = config.age.secrets.ha-bearer-token.path;
        #   metricsPath = "/api/prometheus";
        # };

        jellyfin = mkIf config.chr.services.media.enable {
          targets = ["localhost:8096"];
        };

        cloudflared = mkIf config.services.cloudflared.enable {
          targets = ["localhost:8927"];
        };
        router = mkIf cfg.scrapeRouter {
          targets = ["192.168.2.1:9100"];
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
