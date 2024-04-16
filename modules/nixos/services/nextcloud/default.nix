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
      postgresql.enable = true;
    };
    environment.systemPackages = with pkgs; [
      exiftool
      ffmpeg-headless
    ];
    age.secrets.nc-admin-pass = {
      file = ../../../../secrets/nc-admin-pass;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."cloud.r505.de".listen = [
      {
        addr = "0.0.0.0";
        port = 8070;
      }
    ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      https = true;
      configureRedis = true;
      hostName = "cloud.r505.de";
      autoUpdateApps.enable = true;
      autoUpdateApps.startAt = "05:00:00";
      caching.apcu = true;

      maxUploadSize = "10G";

      enableImagemagick = true;

      #notify_push.enable = true;
      poolSettings = {
        pm = "dynamic";
        "pm.max_children" = "160";
        "pm.max_requests" = "700";
        "pm.max_spare_servers" = "120";
        "pm.min_spare_servers" = "40";
        "pm.start_servers" = "40";
      };

      phpOptions = {
        "date.timezone" = config.time.timeZone;
        "opcache.enable_cli" = "1";
        "opcache.fast_shutdown" = "1";
        "opcache.interned_strings_buffer" = "64";
        "opcache.jit_buffer_size" = "256M";
        "opcache.jit" = "1255";
        "opcache.max_accelerated_files" = "150000";
        "opcache.memory_consumption" = "256";
        "opcache.revalidate_freq" = "60";
        "opcache.save_comments" = "1";
        "openssl.cafile" = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        catch_workers_output = "yes";
        display_errors = "stderr";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        expose_php = "Off";
        max_execution_time = "30";
        max_input_time = "90";
        output_buffering = "0";
        short_open_tag = "Off";
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
        log_type = "file";
        loglevel = 2;
        maintenance_window_start = "12";
        overwriteProtocol = "https";
        profile.enabled = false;
      };
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts mail tasks memories previewgenerator notify_push;
        external = pkgs.fetchNextcloudApp rec {
          url = "https://github.com/nextcloud-releases/external/releases/download/v5.3.1/external-v5.3.1.tar.gz";
          sha256 = "sha256-RCL2RP5twRDLxI/KfAX6QLYQOzqZmSWsfrC5ZQIwTD4=";
          license = "agpl3Only";
        };
      };
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

    services.redis.servers.nextcloud.settings = {
      maxmemory = "512m";
      maxmemory-policy = "volatile-lfu";
    };

    users.users.nextcloud.extraGroups = ["media"];

    # Ensure that postgres is running *before* running the setup
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };
}
