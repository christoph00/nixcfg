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

    services.redis.servers.immich = {
      inherit user;
      enable = true;
    };

    systemd.services.immich-server = {
      description = "immich server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        User = user;
        Group = group;
        ExecStart = ''
          ${pkgs.nodejs}/bin/node ${pkgs.chr.immich-server}/main.js immich
        '';
        WorkingDirectory = "${pkgs.chr.immich-server}/";
        Restart = "on-failure";
        RestartSec = "5";
      };
      environment = {
        NODE_ENV = "production";
        DB_URL = "socket://immich:@/run/postgresql?db=immich";
        REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
        IMMICH_MEDIA_LOCATION = "/nix/persist/immich/upload";
      };
    };
  };
}
