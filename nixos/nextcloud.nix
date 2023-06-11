{
  pkgs,
  lib,
  config,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
  vod-config = jsonFormat.generate "config.json" {
    FFmpeg = "${pkgs.ffmpeg}/bin/ffmpeg";
    FFprobe = "${pkgs.ffmpeg}/bin/ffprobe";
  };
in {
  age.secrets.nc-admin-pass = {
    file = ../secrets/nc-admin-pass;
    owner = "nextcloud";
    mode = "660";
  };
  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = config.services.nginx.user;
    "listen.group" = config.services.nginx.group;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };

  environment.systemPackages = [pkgs.nodejs pkgs.ffmpeg pkgs.go-vod];

  age.secrets.cf-dyndns.file = ../secrets/cf-dyndns;
  services.cloudflare-dyndns = {
    enable = true;
    #ipv6 = true;
    proxied = false;
    domains = ["${config.services.nextcloud.hostName}"];
    apiTokenFile = config.age.secrets.cf-dyndns.path;
  };

  networking.hosts = {
    "127.0.0.1" = config.services.cloudflare-dyndns.domains;
  };

  boot.kernel.sysctl."vm.overcommit_memory" = lib.mkDefault "1";

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];

  users.users.nginx.extraGroups = ["acme" "media"];
  users.users.nextcloud.extraGroups = ["media"];

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      useACMEHost = "r505.de";
    };
  };

  systemd.services.nextcloud-notify_push.after = ["phpfpm-nextcloud.service"];

  systemd.services.imaginary = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.imaginary}/bin/imaginary -p 9000 -concurrency 50 -enable-url-source";
    };
  };

  systemd.services.go-vod = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.go-vod}/bin/go-vod ${vod-config}";
    };
  };

  systemd.services.nextcloud-previewgenerator = {
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ preview:pre-generate";
    serviceConfig.User = "nextcloud";
    startAt = "*:0/10";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    extraApps = {
      memories = pkgs.fetchNextcloudApp rec {
        url = "https://github.com/pulsejet/memories/releases/download/v5.1.0/memories.tar.gz";
        sha256 = "0xa275kswc8jwrzzqf6ghf7zvvbj9khw8hw7sz8rzpnf8cyhlbqb";
      };
      integration_google = pkgs.fetchNextcloudApp rec {
        url = "https://github.com/nextcloud/integration_google/releases/download/v1.0.9/integration_google-1.0.9.tar.gz";
        sha256 = "0fw15p0mkzckr554rvhzmbm7h0pvkiwvqv6zaak7xbyhq0ksxrv4";
      };
      recognize = pkgs.fetchNextcloudApp rec {
        url = "https://github.com/nextcloud/recognize/releases/download/v4.1.0/recognize-4.1.0.tar.gz";
        sha256 = "1cjia6652b952k74503ylj62ikqfc0z1z9qpbrgh3sgc4qnvp93s";
      };
      # facerecognition = pkgs.fetchNextcloudApp rec {
      #   url = "https://github.com/matiasdelellis/facerecognition/releases/download/v0.9.12/facerecognition.tar.gz";
      #   sha256 = "1hz1dcvf5wg41dx95dvzdxp80j8153sp9cfbp0kcgsr6wxdnyxw6";
      # };
      inherit
        (pkgs.nextcloud26Packages.apps)
        bookmarks
        news
        notes
        contacts
        calendar
        tasks
        mail
        deck
        previewgenerator
        files_markdown
        files_texteditor
        notify_push
        onlyoffice
        #twofactor_nextcloud_notification
        
        #twofactor_webauthn
        
        ;
    };
    maxUploadSize = "2048M";

    caching.redis = true;

    https = true;
    # overwriteProtocol = "https";
    #hostName = "SET VIA HOST-CONFIG

    autoUpdateApps.enable = false;

    notify_push.enable = true;
    notify_push.bendDomainToLocalhost = true;

    # phpExtraExtensions = [];
    #home = "SET VIA HOST-CONFIG

    phpOptions."opcache.interned_strings_buffer" = "32";

    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "160";
      "pm.max_requests" = "700";
      "pm.max_spare_servers" = "120";
      "pm.min_spare_servers" = "40";
      "pm.start_servers" = "40";
    };
    extraOptions = {
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
      };
      memcache = {
        local = "\\OC\\Memcache\\Redis";
        distributed = "\\OC\\Memcache\\Redis";
        locking = "\\OC\\Memcache\\Redis";
      };
      memories = {
        vod.path = "${pkgs.go-vod}/bin/go-vod";
        vod.connect = "127.0.0.1:47788";
        vod.vaapi = true;
        vod.ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg";
        vod.ffprobe = "${pkgs.ffmpeg}/bin/ffprobe";

        vod.disable = false;
        vod.external = true;
        exiftool = "${pkgs.exiftool}/bin/exiftool";
        exiftool_no_local = true;
      };
      recognize = {
        node_binary = "${pkgs.nodejs}/bin/node";
      };
    };

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";

      adminuser = "christoph";
      adminpassFile = "${config.age.secrets.nc-admin-pass.path}";

      defaultPhoneRegion = "DE";
    };
  };

  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
    port = 0;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "DATABASE nextcloud" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
