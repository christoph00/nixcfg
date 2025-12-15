{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.vector;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    services.vector = {
      journaldAccess = true;
      settings = {
        api.enabled = true;
        sources.journal = {
          type = "journald";
        };
        sources.host = {
          type = "host_metrics";
        };
        sinks.axiom = {
          type = "axiom";
          inputs = [
            "journal"
            "host"
          ];
          dataset = "journald";
          # token = "${AXIOM_TOKEN}";
        };
      };
    };

    systemd.services.vector.serviceConfig.EnvironmentFile = config.secrets.files."vector.env".path;

    secrets.files."vector.env" = {
      path = "/var/lib/vector/secrets.env";
      owner = "vector";
      group = "vector";
    };
  };
}
