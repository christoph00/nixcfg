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
  options.chr.services.mqtt = with types; {
    enable = mkBoolOpt' false;
  };
  config = mkIf cfg.enable {
    environment.persistence."/persist".directories = [
      {
        directory = "/var/lib/paperless";
        user = "paperless";
        group = "paperless";
        mode = "0750";
      }
    ];

    services.paperless = {
      enable = true;
      address = "0.0.0.0";
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

    systemd.services.paperless.serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
