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
      settings = {
        PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";
        PAPERLESS_ENABLE_COMPRESSION = false;
        PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 8;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_TASK_WORKERS = 4;
        PAPERLESS_WEBSERVER_WORKERS = 4;
        PAPERLESS_CONVERT_TMPDIR = "${config.chr.system.persist.stateDir}/paperless/tmp";
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "docs.r505.de" = "http://localhost:${builtins.toString config.services.paperless.port}";
      };
    };

    systemd.services.paperless-sftpgo = {
      description = "Allow group access to paperless files";
      serviceConfig = {Type = "oneshot";};
      wantedBy = ["paperless-consumer.service"];
      script = ''
        inotifywait -m -e create "/mnt/userdata/inbox" |
        while read -r DIR FILE; do
          rsync -avog --remove-source-files --chown=paperless:paperless "/mnt/userdata/inbox/$FILE" "${config.services.paperless.consumtionDir}/"
        done
      '';
    };

    systemd.services.paperless.serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
