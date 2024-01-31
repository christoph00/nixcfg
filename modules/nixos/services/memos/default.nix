{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib.chr; let
  cfg = config.chr.services.memos;
in {
  options = with lib; {
    chr.services.memos = {
      enable = mkEnableOption "Enable memos";
      container = mkBoolOpt true "Enable memos in container";

      directory = mkOption {
        type = types.str;
        default = "${config.chr.system.persist.stateDir}/memos";
        description = "Persistent directory to house database.";
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Address to run memos on.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 7030;
        description = "Port to listen on";
      };

      user = mkOption {
        type = with types; oneOf [str int];
        default = "memos";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [str int];
        default = "memos";
        description = ''
          The user the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.chr.memos;
        defaultText = literalExpression "pkgs.chr.memos";
        description = "The package to use for memos";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.memos = {};
    users.users.memos = {
      description = "memos service user";
      isSystemUser = true;
      home = "${cfg.directory}";
      createHome = true;
      group = "memos";
    };

    systemd.services.memos = lib.mkIf (!cfg.container) {
      enable = true;
      description = "Lightweight note-taking service";
      wantedBy = ["multi-user.target"];
      after = ["networking.service"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/memos -m prod -p ${toString cfg.port} -d ${cfg.directory}";
      };
    };

    virtualisation.oci-containers.containers.memos = lib.mkIf cfg.container {
      image = "ghcr.io/usememos/memos:0.19.1";
      autoStart = true;
      hostname = "memos";
      volumes = ["${cfg.directory}:/var/opt/memos"];
      environment = {
        MEMOS_PORT = "${toString cfg.port}";
      };
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "mem.r505.de" = "http://127.0.0.1:7030";
      };
    };
  };
}
