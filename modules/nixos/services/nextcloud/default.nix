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
    enableImaginary = mkBoolOpt true "Enable Imaginary Service.";
    port = mkOption {
      type = types.int;
      default = 8070;
      description = "Port nextcloud listens on.";
    };
  };
  config = mkIf cfg.enable {
    chr.services = {
      postgresql.enable = true;
    };
    environment.systemPackages = with pkgs; [
      exiftool
      jellyfin-ffmpeg
      perl
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
        port = cfg.port;
      }
    ];

    services.imaginary = lib.mkIf cfg.enableImaginary {
      enable = true;
      address = "127.0.0.1";
      settings.return-size = true;
    };

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
        preview_imaginary_url = "http://localhost:8088";

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

          "OC\\Preview\\Image" # alias for png,jpeg,gif,bmp

          "OC\\Preview\\Imaginary"

          "OC\\Preview\\Font"
          "OC\\Preview\\PDF"
          "OC\\Preview\\SVG"
          "OC\\Preview\\WebP"
        ];

        log_type = "file";
        loglevel = 2;
        maintenance_window_start = "12";
        overwriteProtocol = "https";
        profile.enabled = false;
        default_phone_region = "DE";

        "memories.vod.ffmpeg" = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
        "memories.vod.ffprobe" = "${pkgs.jellyfin-ffmpeg}/bin/ffprobe";
        "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
        "memories.exiftool_no_local" = true;
        jpeg_quality = 60;
        preview_max_filesize_image = 128; # MB
        preview_max_memory = 512; # MB
        preview_max_x = 2048; # px
        preview_max_y = 2048; # px
      };
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit
          calendar
          contacts
          mail
          memories
          previewgenerator
          notify_push
          notes
          ;
        external = pkgs.fetchNextcloudApp rec {
          url = "https://github.com/nextcloud-releases/external/releases/download/v5.3.1/external-v5.3.1.tar.gz";
          sha256 = "sha256-RCL2RP5twRDLxI/KfAX6QLYQOzqZmSWsfrC5ZQIwTD4=";
          license = "agpl3Only";
        };
        integration_excalidraw = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/integration_excalidraw/releases/download/v2.1.0/integration_excalidraw-v2.1.0.tar.gz";
          sha256 = "sha256-NZGu6+KxeXQP23brkpkUbrzglDAy1P9dyQEAf7muwKE=";
          license = "agpl3Only";
        };
        integration_google = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/integration_google/releases/download/v2.2.0/integration_google-v2.2.0.tar.gz";
          sha256 = "sha256-pMC6u+vJvw1E8WHEcQ63CGtXL0v3sVZQH8MJywK7dnc=";
          license = "agpl3Only";
        };
        integration_github = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/integration_github/releases/download/v2.0.7/integration_github-v2.0.7.tar.gz";
          sha256 = "sha256-2X/bNQNs3gC/EKeLQKjzMTslUPY6uHWcoT7wayhFQXk=";
          license = "agpl3Only";
        };
        fulltextsearch = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/fulltextsearch/releases/download/28.0.1/fulltextsearch-28.0.1.tar.gz";
          sha256 = "sha256-so6k8kB+o9PJ+FHX32riZhMJLRbGqrySRpzMmC3VzJI=";
          license = "agpl3Only";
        };
        tables = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/tables/releases/download/v0.7.0-beta.2/tables.tar.gz";
          sha256 = "sha256-so6k8kB+o9PJ+FHX32riZhMJLRbGqrySRpzMmC3VzJI=";
          license = "agpl3Only";
        };
      };
    };

    services.phpfpm.pools = {
      # add user packages to phpfpm process PATHs, required to find ffmpeg for preview generator
      # beginning taken from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.nix#L985
      nextcloud.phpEnv.PATH = lib.mkForce "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin:/etc/profiles/per-user/nextcloud/bin";
    };

    systemd.services.nextcloud-cron = {
      path = [pkgs.perl];
    };

    systemd.services."phpfpm-nextcloud".serviceConfig = {
      DeviceAllow = ["/dev/dri/renderD128"];
      SupplementaryGroups = [
        "render"
        "video"
      ];
      UMask = "0077";
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "cloud.r505.de" = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    services.traefik.dynamicConfigOptions.http.routers.nextcloud = {
      entryPoints = ["https" "http"];
      rule = "Host(`cloud.internal.r505.de`)";
      service = "nextcloud";
      tls.domains = [{main = "*.internal.r505.de";}];
      tls.certResolver = "cfWildcard";
    };
    services.traefik.dynamicConfigOptions.http.services.nextcloud.loadBalancer = {
      passHostHeader = false;
      servers = [{url = "http://127.0.0.1:${toString cfg.port}";}];
    };

    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [{directory = "/var/lib/nextcloud";}];
    };

    services.redis.servers.nextcloud.settings = {
      maxmemory = "512m";
      maxmemory-policy = "volatile-lfu";
    };

    users.users.nextcloud.extraGroups = ["media"];

    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    # systemd.services."go-vod" = {
    #   path = with pkgs; [
    #     jellyfin-ffmpeg
    #   ];
    #   serviceConfig = {
    #     DynamicUser = true;
    #     ExecStart = "${pkgs.chr.go-vod}/bin/go-vod";
    #     DeviceAllow = ["/dev/dri/renderD128" "/dev/dri/renderD129"];
    #     ReadOnlyPaths = config.services.nextcloud.home;
    #     SupplementaryGroups = ["nextcloud"];
    #   };
    # };
  };
}
