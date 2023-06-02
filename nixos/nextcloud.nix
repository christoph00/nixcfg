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

  # services.imaginary = {
  #   enable = true;
  #   settings = {
  #     enable-url-source = true;
  #   };
  # };

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

    # phpExtraExtensions = [];
    #home = "SET VIA HOST-CONFIG

    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "160";
      "pm.max_requests" = "700";
      "pm.max_spare_servers" = "120";
      "pm.min_spare_servers" = "40";
      "pm.start_servers" = "40";
    };
    extraOptions = {
      phpOptions = ''
        short_open_tag = "Off";
        expose_php = "Off";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        display_errors = "stderr";
        "opcache.enable_cli" = "1";
        "opcache.enable" = "1";
        "opcache.interned_strings_buffer" = "12";
        "opcache.max_accelerated_files" = "10000";
        "opcache.memory_consumption" = "128";
        "opcache.save_comments" = "1";
        "opcache.revalidate_freq" = "1";
        "opcache.fast_shutdown" = "1";
        "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
        catch_workers_output = "yes";
        memory_limit = "1024M";
      '';
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
