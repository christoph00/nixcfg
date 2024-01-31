{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs; let
  cfg = config.chr.services.yarr;
in {
  options = with lib; {
    chr.services.yarr = {
      enable = mkEnableOption "Enable yarr";

      directory = mkOption {
        type = types.str;
        default = "${config.chr.system.persist.stateDir}/yarr";
        description = "Persistent directory to house database.";
      };

      basePath = mkOption {
        type = types.str;
        default = "";
        description = "Base path of the service URL.";
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Address to run yarr on.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 7070;
        description = "Port to listen on";
      };

      dbPath = mkOption {
        type = types.str;
        default = "${cfg.directory}/storage.db";
        description = "Full path to the database file.";
      };

      user = mkOption {
        type = with types; oneOf [str int];
        default = "yarr";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [str int];
        default = "yarr";
        description = ''
          The user the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.yarr;
        defaultText = literalExpression "pkgs.yarr";
        description = "The package to use for yarr";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.yarr = {};
    users.users.yarr = {
      description = "Yarr service user";
      isSystemUser = true;
      home = "${cfg.directory}";
      createHome = true;
      group = "yarr";
    };

    systemd.services.yarr = {
      enable = true;
      description = "Yet Another Rss Reader server";
      wantedBy = ["multi-user.target"];
      after = ["networking.service"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/yarr -addr ${cfg.address}:${
          toString cfg.port
        } -db ${cfg.dbPath} -auth-file ${config.age.secrets.yarr-auth.path}";
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "rss.r505.de" = "http://127.0.0.1:7070";
      };
    };
    age.secrets.yarr-auth = {
      file = ../../../../secrets/yarr-auth;
      owner = cfg.user;
      group = cfg.group;
    };
  };
}
