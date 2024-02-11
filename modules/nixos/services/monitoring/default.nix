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
    scrapeExtra = mkBoolOpt false "Enable scraping External entpoints.";
  };
  config = mkIf cfg.enable {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9100;
        };
      };
    };
    services.vmagent = {
      enable = true;
      package = pkgs.victoriametrics;
      remoteWriteUrl =
        lib.mkForce
        "http://air13.netbird.cloud:8428/api/v1/write"; #TODO: fix hardcoded URL
      extraArgs =
        lib.mkForce
        ["-remoteWrite.label=instance=${config.networking.hostName}"];
      prometheusConfig = {
        global = {
          scrape_interval = "1m";
          scrape_timeout = "30s";
        };
        scrape_configs =
          [
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [
                    "localhost:${
                      toString config.services.prometheus.exporters.node.port
                    }"
                  ];
                }
              ];
            }
          ]
          ++ lib.optionals cfg.scrapeExtra [
            {
              job_name = "openwrt";
              static_configs = [
                {
                  targets = [
                    "192.168.2.1:9100"
                  ];
                }
              ];
            }
          ];
      };
    };
  };
}
