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
      #dataDir = "${config.chr.system.persist.stateDir}/paperless";
      mediaDir = "/mnt/userdata/paperless";
      settings = {
        PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";
        PAPERLESS_ENABLE_COMPRESSION = true;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_CONVERT_TMPDIR = "${config.services.paperless.dataDir}/tmp";
        PAPERLESS_SCRATCH_DIR = "${config.services.paperless.dataDir}/scratch";
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "docs.r505.de" = "http://localhost:${builtins.toString config.services.paperless.port}";
      };
    };

    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [
        {
          directory = "/var/lib/paperless";
        }
      ];
    };

    age.secrets.paperless-token-env.file = ../../../../secrets/paperless-token.env;

    systemd.services.paperless-sftpgo = {
      description = "Move files from sftpgo inbox to paperless consumption directory";
      wantedBy = ["paperless-consumer.service"];
      serviceConfig = {
        EnvironmentFile = config.age.secrets.paperless-token-env.path;
        # ExecStart = let
        #   plurl = "http://localhost:${builtins.toString config.services.paperless.port}";
        # in "${pkgs.chr.scantopl}/bin/scantopl -scandir /mnt/userdata/inbox -plurl ${plurl}";
      };
      script = let
        plurl = "http://localhost:${builtins.toString config.services.paperless.port}";
      in ''
        ${pkgs.inotify-tools}/bin/inotifywait -m -e close_write "/mnt/userdata/inbox" |
        while read -r directory action file; do
          echo "Neue Datei $file erkannt. Sende an Paperless..."
          ${pkgs.curl}/bin/curl ${plurl}/api/documents/post_document/ -X POST \
            -H "Authorization: Token $PLTOKEN" \
            -F "document=@/mnt/userdata/inbox/$file" \
            -F "title=$file"
          if [ $? -eq 0 ]; then
            echo "Datei $file erfolgreich gesendet. Lösche Datei..."
            rm "/mnt/userdata/inbox/$file"
          else
            echo "Fehler beim Senden der Datei $file."
          fi
        done
      '';
    };

    systemd.services.paperless.serviceConfig.RestartSec = "600"; # Retry every 10 minutes
  };
}
