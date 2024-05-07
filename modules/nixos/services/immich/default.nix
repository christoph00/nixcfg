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
    dataDir = mkOption {
      type = types.str;
      default = "/nix/persist/immich";
      description = ''
        Directory to store data
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

    systemd.services = let
      environment = {
        NODE_ENV = "production";
        DB_URL = "socket://immich:@/run/postgresql?db=immich";
        REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
        IMMICH_MEDIA_LOCATION = "/nix/persist/immich/upload";
        IMMICH_WEB_ROOT = "${pkgs.chr.immich}/web";
      };
    in {
      immich-server = {
        inherit environment;
        description = "immich server";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          User = user;
          Group = group;
          ExecStart = ''
            ${pkgs.nodejs}/bin/node ${pkgs.chr.immich}/main.js immich
          '';
          WorkingDirectory = "${pkgs.chr.immich}/";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };
      immich-microservices = {
        inherit environment;
        description = "immich microservices";
        wantedBy = ["immich-server.service"];
        after = ["immich-server.service"];
        serviceConfig = {
          User = user;
          Group = group;
          ExecStart = ''
            ${pkgs.nodejs}/bin/node ${pkgs.chr.immich}/main.js microservices
          '';
          WorkingDirectory = "${pkgs.chr.immich}/";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "img.r505.de" = "http://127.0.0.1:3001";
      };
    };
  };
}
