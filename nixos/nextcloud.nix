{
  pkgs,
  lib,
  ...
}: {
  age.secrets.nc-admin-pass.file = ../secrets/nc-admin-pass;

  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = config.services.caddy.user;
    "listen.group" = config.services.caddy.group;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    https = true;
    # overwriteProtocol = "https";
    hostName = "cloud.r505.de";

    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";

    # phpExtraExtensions = [];
    home = "/var/lib/nextcloud";

    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "160";
      "pm.max_requests" = "700";
      "pm.max_spare_servers" = "120";
      "pm.min_spare_servers" = "40";
      "pm.start_servers" = "40";
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

  services.caddy.virtualHosts = {
    "cloud.r505.de".extraConfig = ''
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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
