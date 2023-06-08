{
  pkgs,
  lib,
  config,
  ...
}: {
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
      ProtectProc = "invisible";
      NoNewPrivileges = true;
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      PrivateMounts = true;
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      DevicePolicy = "closed";
    };
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
      inherit
        (pkgs.nextcloud26Packages.apps)
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
        twofactor_nextcloud_notification
        twofactor_webauthn
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
