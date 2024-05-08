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

    environment.systemPackages = with pkgs; [
      immich-go
    ];

    systemd.services = let
      environment = {
        NODE_ENV = "production";
        DB_URL = "socket://immich:@/run/postgresql?db=immich";
        REDIS_SOCKET = config.services.redis.servers.immich.unixSocket;
        IMMICH_MEDIA_LOCATION = "/nix/persist/immich/upload";
        IMMICH_REVERSE_GEOCODING_ROOT = "/nix/persist/immich/geocoding";
        IMMICH_WEB_ROOT = "${pkgs.chr.immich}/web";
      };
      path = with pkgs; [
        perlPackages.ImageExifTool
        perlPackages.FileMimeInfo
        exiftool
        jellyfin-ffmpeg
      ];
    in {
      immich-server = {
        inherit environment path;
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
        inherit environment path;
        description = "immich microservices";
        wantedBy = ["multi-user.target"];
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
      immich-ml = {
        inherit environment path;
        description = "immich machine-learning";
        wantedBy = ["multi-user.target"];
        after = ["immich-server.service"];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.chr.immich-ml.python.pkgs.gunicorn}/bin/gunicorn app.main:app \
              -k app.config.CustomUvicornWorker \
              -w 1 \
              -b 127.0.0.1:3002 \
              -t 120 \
              --graceful-timeout 0
          '';
          WorkingDirectory = "${pkgs.chr.immich-ml}/lib/python3.11/site-packages";
          Restart = "on-failure";
          RestartSec = "5";
        };
        environment =
          environment
          // {
            PYTHONPATH = "${pkgs.chr.immich-ml.python.pkgs.makePythonPath pkgs.chr.immich-ml.propagatedBuildInputs}";
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
