# https://github.com/hbjydev/dots.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  grafanaAgentLib = import ./river-lib.nix;
  inherit (grafanaAgentLib) buildScrapeSet;

  cfg = config.services.grafana-agent-flow;

  grafanaCloudOpts = {
    options = {
      enable = mkOption {
        description = "Enable Grafana Cloud configuration";
        type = types.bool;
        default = false;
      };

      stack = mkOption {
        description = "Grafana Cloud stack";
        type = types.str;
        default = "";
      };

      tokenFile = mkOption {
        description = "Grafana Cloud API token file path";
        type = types.path;
        default = "";
      };
    };
  };

  staticScrapeOpts = {name, ...}: {
    options = {
      bearerTokenFile = mkOption {
        description = "Bearer token file path";
        type = types.str;
        default = "";
      };

      targets = mkOption {
        description = "List of targets to scrape";
        type = types.listOf types.str;
        default = [];
      };

      forwardTo = mkOption {
        description = "List of targets to forward to";
        type = types.listOf types.str;
        default = ["module.git.grafana_cloud.exports.metrics_receiver"];
      };

      metricsPath = mkOption {
        description = "Metrics path";
        type = types.str;
        default = "/metrics";
      };

      scrapeInterval = mkOption {
        description = "Scrape interval";
        type = types.str;
        default = "10s";
      };
    };
  };
in {
  options = {
    services.grafana-agent-flow = {
      enable = mkEnableOption (mdDoc "grafana-agent-flow");
      package = mkPackageOption pkgs "grafana-agent" {};

      nodeExporter = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable node exporter";
            };

            forwardTo = mkOption {
              type = types.listOf types.str;
              default = ["module.git.grafana_cloud.exports.metrics_receiver"];
              description = "List of targets to forward to";
            };
          };
        };

        default = {};
      };

      enableJournaldLogging = mkOption {
        default = false;
        type = types.bool;
        description = mdDoc ''
          Enable journald logging.
        '';
      };

      extraConfig = mkOption {
        default = "";
        type = types.str;
        description = mdDoc ''
          Extra configuration to add to the agent configuration file.
        '';
      };

      grafanaCloud = mkOption {
        default = {};
        type = types.submodule grafanaCloudOpts;
        description = mdDoc ''
          Grafana Cloud configuration.
        '';
      };

      httpListenAddr = mkOption {
        default = "127.0.0.1:12345";
        type = types.str;
        description = mdDoc ''
          Address to listen on for HTTP requests.
        '';
      };

      staticScrapes = mkOption {
        default = {};
        type = with types; attrsOf (submodule staticScrapeOpts);
        description = mdDoc ''
          List of static scrapes to configure.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.grafana-agent-flow = {
      group = "grafana-agent-flow";
      description = "grafana-agent-flow user";
      home = "/var/lib/grafana-agent-flow";
      createHome = true;
      isNormalUser = true;
    };

    users.groups.grafana-agent-flow = {};

    systemd.services.grafana-agent-flow = {
      description = "grafana-agent-flow";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        AGENT_MODE = "flow";
      };

      serviceConfig = let
        tokenFile =
          if cfg.grafanaCloud.enable
          then ''
            local.file "gc_token" {
              filename = "${cfg.grafanaCloud.tokenFile}"
              is_secret = true
            }
          ''
          else "";

        nodeExporterConfig =
          if cfg.nodeExporter.enable
          then ''
            prometheus.scrape "node" {
              targets = prometheus.exporter.unix.node.targets
              forward_to = [
                ${builtins.concatStringsSep ",\n" cfg.nodeExporter.forwardTo},
              ]
              scrape_interval = "10s"
            }
            prometheus.exporter.unix "node" {
            }
          ''
          else "";

        journaldLoggingConfig =
          if cfg.enableJournaldLogging
          then ''
            loki.relabel "journal" {
              forward_to = []

              rule {
                source_labels = ["__journal__systemd_unit"]
                target_label  = "unit"
              }
              rule {
                source_labels = ["__journal__boot_id"]
                target_label  = "boot_id"
              }
              rule {
                source_labels = ["__journal__transport"]
                target_label  = "transport"
              }
              rule {
                source_labels = ["__journal_priority_keyword"]
                target_label  = "level"
              }
              rule {
                source_labels = ["__journal__hostname"]
                target_label  = "instance"
              }
            }

            loki.source.journal "read" {
              forward_to = [module.git.grafana_cloud.exports.logs_receiver]
              relabel_rules = loki.relabel.journal.rules
            }
          ''
          else "";

        configFile = pkgs.writeText "config.river" ''
          ${tokenFile}

          module.git "grafana_cloud" {
            repository = "https://github.com/grafana/agent-modules.git"
            path = "modules/grafana-cloud/autoconfigure/module.river"
            revision = "main"
            pull_frequency = "0s"
            arguments {
              stack_name = "${cfg.grafanaCloud.stack}"
              token = local.file.gc_token.content
            }
          }

          ${journaldLoggingConfig}
          ${nodeExporterConfig}

          ${buildScrapeSet cfg.staticScrapes}

          ${cfg.extraConfig}
        '';
      in {
        ExecStart = "${lib.getExe cfg.package} run ${configFile} --storage.path /var/lib/grafana-agent-flow --server.http.listen-addr ${cfg.httpListenAddr}";
        Restart = "always";
        User = "grafana-agent-flow";
        Group = "grafana-agent-flow";
        RestartSec = "30s";
        StateDirectory = "grafana-agent-flow";
        Type = "simple";
      };
    };
  };
}
