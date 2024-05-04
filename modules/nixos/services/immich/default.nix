{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.immich;
  user = "immich";
  group = user;
  uid = 15015;
  gid = uid;
in {
  options.chr.services.immich = with types; {
    enable = mkBoolOpt false "Enable immich Service.";
    port = mkOption {
      type = types.port;
      default = 8081;
      description = ''
        Port the listener should listen on
      '';
    };
    version = mkOption {
      type = types.str;
      default = "release";
      description = ''
        Version of the immich server to use
      '';
    };
    dataDir = mkOption {
      type = types.str;
      default = "/nix/persist/immich";
      description = ''
        Directory to store data
      '';
    };

    dbHostname = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        Hostname of the database
      '';
    };
    dbPort = mkOption {
      type = types.int;
      default = 5432;
      description = ''
        Port of the database
      '';
    };

    dbDatabase = mkOption {
      type = types.str;
      default = "immich";
      description = ''
        Database name
      '';
    };
    dbUsername = mkOption {
      type = types.str;
      default = "immich";
      description = ''
        Database username
      '';
    };
    dbPasswordFile = mkOption {
      type = types.str;
      default = "/run/secrets/immich-db-password";
      description = ''
        Database password file
      '';
    };

    redisHostname = mkOption {
      type = types.str;
      default = "localhost";
      description = ''
        Hostname of the redis server
      '';
    };

    redisPort = mkOption {
      type = types.int;
      default = 6379;
      description = ''
        Port of the redis server
      '';
    };
  };
  config = mkIf cfg.enable {
    users.users.${user} = {
      inherit group uid;
      isSystemUser = true;
    };
    users.groups.${group} = {inherit gid;};

    virtualisation.oci-containers.containers = {
      "immich-server" = {
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        cmd = [
          "start.sh"
          "immich"
        ];
        volumes = [
          "${cfg.dataDir}:/usr/src/app/upload"
          "/run/agenix:/run/agenix:ro"
          "/run/postgresql:/run/postgresql:ro"
          "/run/redis-immich:/run/redis-immich:ro"
        ];
        environment = {
          PUID = toString uid;
          PGID = toString gid;
          DB_URL = "socket://immich:@/run/postgresql?db=immich";
          REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
        };
        autoStart = true;
        extraOptions = ["--pod=immich"];
      };
      "immich-microservices" = {
        image = "ghcr.io/immich-app/immich-server:${cfg.version}";
        cmd = [
          "start.sh"
          "microservices"
        ];

        volumes = [
          "${cfg.dataDir}:/usr/src/app/upload"
          "/run/agenix:/run/agenix:ro"
          "/run/postgresql:/run/postgresql:ro"
          "/run/redis-immich:/run/redis-immich:ro"
        ];
        environment = {
          PUID = toString uid;
          PGID = toString gid;
          DB_URL = "socket://immich:@/run/postgresql?db=immich";
          REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
        };
        autoStart = true;
        extraOptions = ["--pod=immich"];
      };
      "immich-machine-learning" = {
        image = "ghcr.io/immich-app/immich-machine-learning:${cfg.version}";
        volumes = ["model-cache:/usr/src/app/upload"];
        autoStart = true;
        environment = {
          PUID = toString uid;
          PGID = toString gid;
        };
        extraOptions = ["--pod=immich"];
      };
    };

    systemd.services.podman-immich-server.serviceConfig.Type = lib.mkForce "exec";
    systemd.services.podman-immich-microservices.serviceConfig.Type = lib.mkForce "exec";
    systemd.services.podman-immich-machine-learning.serviceConfig.Type = lib.mkForce "exec";

    systemd.services.podman-create-pod-immich = {
      serviceConfig.Type = "oneshot";
      wantedBy = [
        "podman-immich-server.service"
        "podman-immich-microservices.service"
        "podman-immich-machinelearning.service"
      ];

      script = ''
        ${pkgs.podman}/bin/podman pod create --name immich --replace -p '${toString cfg.port}:3001'
      '';
    };

    services.redis.servers.immich = {
      inherit user;
      enable = true;
    };
  };
}
