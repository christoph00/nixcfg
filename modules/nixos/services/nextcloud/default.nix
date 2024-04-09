{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.nextcloud;
in {
  options.chr.services.nextcloud = with types; {
    enable = mkBoolOpt false "Enable nextcloud Service.";
  };
  config = mkIf cfg.enable {
    chr.services = {
      webserver.enable = true;
      postgresql.enable = true;
    };
    environment.systemPackages = with pkgs; [
      exiftool
      ffmpeg
    ];
    age.secrets.nc-admin-pass = {
      file = ../../../../secrets/nc-admin-pass;
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      https = true;
      hostName = "cloud.r505.de";
      autoUpdateApps.enable = true;
      autoUpdateApps.startAt = "05:00:00";
      home = "/mnt/userdata/ncloud";
      notify_push.enable = true;
      poolSettings = {
        pm = "dynamic";
        "pm.max_children" = "160";
        "pm.max_requests" = "700";
        "pm.max_spare_servers" = "120";
        "pm.min_spare_servers" = "40";
        "pm.start_servers" = "40";
      };
      config = {
        # Database
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";

        # Admin user
        adminuser = "christoph";
        adminpassFile = "${config.age.secrets.nc-admin-pass.path}";
      };
      extraOptions.enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Movie"
      ];
    };
    services.caddy.virtualHosts = {
      "127.0.0.1:8070".extraConfig = ''

        redir /.well-known/carddav /remote.php/dav 301
        redir /.well-known/caldav /remote.php/dav 301

        @forbidden {
            path /.htaccess
            path /data/*
            path /config/*
            path /db_structure
            path /.xml
            path /README
            path /3rdparty/*
            path /lib/*
            path /templates/*
            path /occ
            path /console.php
        }
        respond @forbidden 404

        root * ${config.services.nextcloud.package}
        file_server
        php_fastcgi unix//run/phpfpm/nextcloud.sock
      '';
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "cloud.r505.de" = "http://127.0.0.1:8070";
      };
    };

    # Ensure that postgres is running *before* running the setup
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };
}
