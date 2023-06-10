{
  config,
  lib,
  pkgs,
  ...
}: let
  dataDir = "/mnt/userdata/immich";
  uploadDir = "/mnt/userdata/upload";
  dbPasswordFile = "...";
in {
  age.secrets.immich-env.file = ../secrets/immich-env;
  age.secrets.immich-db-password.file = ../secrets/immich-db-password;

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_14;
    ensureDatabases = ["immich"];
    ensureUsers = [
      {
        name = "immich";
        ensurePermissions."DATABASE immich" = "ALL PRIVILEGES";
      }
    ];
  };

  services.redis.servers.immich = {
    enable = true;
    port = 31640;
  };

  systemd.services.immich-init = {
    enable = true;
    description = "Set up paths & database access";
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
    before = [
      "immich-server.service"
      #    "immich-microservices.service"
      #     "immich-machine-learning.service"
      #      "immich-web.service"
    ];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = ["db_password:${dbPasswordFile}"];
    };
    script = ''
      mkdir -p ${dataDir} ${uploadDir}
      echo "Set immich postgres user password"
      db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
      ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql postgres \
        -c "alter user immich with password '$db_password'"
    '';
  };

  systemd.services.immich-server = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      NODE_ENV = "production";
      DB_HOSTNAME = "localhost";
      DB_USERNAME = "immich";
      DB_PASSWORD = "immich";
      DB_DATABASE_NAME = "immich";
      UPLOAD_LOCATION = "/mnt/userdata/immich";
      #TYPESENSE_API_KEY = "23942984928392";

      IMMICH_WEB_URL = "http://localhost:3000";
      IMMICH_SERVER_URL = "http://localhost:3001";
      IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";

      LOG_LEVEL = "debug";

      REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
      REDIS_HOSTNAME = "localhost";
    };
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.immich-server}/dist/apps/immich/apps/immich/src/main.js";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "r505.de";
    forceSSL = true;
    locations."/api" = {
      proxyPass = "http://localhost:3001";
      extraConfig = ''
        rewrite /api/(.*) /$1 break;
        client_max_body_size 50000M;
      '';
    };
    locations."/" = {
      proxyPass = "http://localhost:3000";
      extraConfig = ''
        client_max_body_size 50000M;
      '';
    };
  };
}
