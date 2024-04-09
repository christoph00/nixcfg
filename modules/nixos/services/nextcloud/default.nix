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
  cloudflareIpRanges = [
    # Cloudflare IPv4: https://www.cloudflare.com/ips-v4
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"

    # Cloudflare IPv6: https://www.cloudflare.com/ips-v6
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];
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
      owner = "nextcloud";
      group = "nextcloud";
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
      caching.apcu = true;

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
      settings = {
        trusted_proxies = cloudflareIpRanges;
        enabledPreviewProviders = [
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
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts mail news notify_push files_markdown;
      };
    };
    services.caddy.virtualHosts = {
      ":8070".extraConfig = ''

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

    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [
        {
          directory = "/var/lib/nextcloud";
        }
      ];
    };

    # Ensure that postgres is running *before* running the setup
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };
}
