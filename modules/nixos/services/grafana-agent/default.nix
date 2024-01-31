{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.grafana-agent;
in {
  options.chr.services.grafana-agent = with types; {
    enable = mkBoolOpt true "Enable grafana-agent Service.";
  };
  config = mkIf cfg.enable {
    age.secrets.grafana-password = {
      file = ../../../../secrets/grafana-password;
    };
    services.grafana-agent = {
      enable = true;
      credentials = {
        LOGS_REMOTE_WRITE_PASSWORD = config.age.secrets.grafana-logs-password.path;
        METRICS_REMOTE_WRITE_PASSWORD = config.age.secrets.grafana-password.path;
      };
      settings = {
        metrics = {
          global = {
            scrape_interval = "60s";
            remote_write = [
              {
                basic_auth = {
                  username = "573879";
                  password = "\${METRICS_REMOTE_WRITE_PASSWORD}";
                };
                url = "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push";
              }
            ];
          };
        };
        logs = {
          configs = [
            {
              clients = [
                {
                  basic_auth = {
                    username = "285909";
                    password = "\${METRICS_REMOTE_WRITE_PASSWORD}";
                  };
                  url = "https://logs-prod-eu-west-0.grafana.net";
                }
              ];
              name = "default";
              positions = {
                filename = "\${STATE_DIRECTORY}/loki_positions.yaml";
              };
              scrape_configs = [
                {
                  job_name = "journal";
                  journal = {
                    labels = {
                      job = "systemd-journal";
                    };
                    max_age = "12h";
                  };
                  relabel_configs = [
                    {
                      source_labels = [
                        "__journal__systemd_unit"
                      ];
                      target_label = "systemd_unit";
                    }
                    {
                      source_labels = [
                        "__journal__hostname"
                      ];
                      target_label = "nodename";
                    }
                    {
                      source_labels = [
                        "__journal_syslog_identifier"
                      ];
                      target_label = "syslog_identifier";
                    }
                  ];
                }
              ];
            }
          ];
        };

        integrations = {
          agent.enabled = true;
          agent.scrape_integration = true;
          node_exporter.enabled = true;
        };
      };
    };
  };
}
