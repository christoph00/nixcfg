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
      dataDir = "/nix/persist/paperless";
      consumptionDirIsPublic = true;
      #passwordFile = config.age.secrets.paperless-admin-password.path;
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
        "docs.r505.de" = "http://127.0.0.1:28981";
      };
    };

    systemd.services.paperless.serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
