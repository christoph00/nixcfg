{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.paperless;
in {
  options.chr.services.paperless = with types; {
    enable = mkBoolOpt' config.chr.services.nas.enable;
  };
  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      dataDir = "${config.chr.system.persist.stateDir}/paperless";
      consumptionDir = "${config.chr.system.persist.stateDir}/paperless-consumption";
      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";
        PAPERLESS_ENABLE_COMPRESSION = false;
        PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 8;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_TASK_WORKERS = 4;
        PAPERLESS_WEBSERVER_WORKERS = 4;
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "docs.r505.de" = "http://localhost:${builtins.toString config.services.paperless.port}";
      };
    };

    # Fix permissions on a regular schedule
    systemd.timers.paperless-permissions = {
      timerConfig = {
        OnCalendar = "*-*-* *:0/10"; # Every 10 minutes
        Unit = "paperless-permissions.service";
      };
      wantedBy = ["timers.target"];
    };

    # Fix paperless shared permissions
    systemd.services.paperless-permissions = {
      description = "Allow group access to paperless files";
      serviceConfig = {Type = "oneshot";};
      script = ''
        find ${config.services.paperless.consumptionDir} -type f -exec chmod 640 -- {} +
      '';
    };

    systemd.services.paperless.serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
