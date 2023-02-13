{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.olivetin;
  format = pkgs.formats.yaml {};
  configFile = format.generate "config.yaml" cfg.settings;
  defaultUser = "olivetin";
  defaultGroup = defaultUser;
in {
  options = {
    services.olivetin = {
      enable = mkEnableOption "olivetin";
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open ports in the firewall for olivetin.
        '';
      };
      user = mkOption {
        type = types.str;
        default = defaultUser;
        example = "yourUser";
        description = mdDoc ''
          The user to run olivetin as.
        '';
      };

      group = mkOption {
        type = types.str;
        default = defaultGroup;
        example = "yourGroup";
        description = mdDoc ''
          The group to run olivetin under.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sftpgo;
        defaultText = literalExpression "pkgs.olivetin";
        description = mdDoc ''
          Which olivetin package to use.
        '';
      };

      settings = mkOption {
        type = format.type;
        description = lib.mdDoc ''
            olivetin config
          `${configFile}`
        '';
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [1337];
    };
    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        uid = 456;
        description = "olivetin daemon user";
        isSystmUser = true;
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup}.gid =
        456;
    };
    systemd.services.olivetin = {
      description = "OliveTin gives safe and simple access to predefined shell commands from a web interface";
      wants = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/olivetin -configdir ${configFile}";
        User = cfg.user;
        Group = cfg.group;

        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        CapabilityBoundingSet = [
          "~CAP_SYS_PTRACE"
          "~CAP_SYS_ADMIN"
          "~CAP_SETGID"
          "~CAP_SETUID"
          "~CAP_SETPCAP"
          "~CAP_SYS_TIME"
          "~CAP_KILL"
        ];

        # Required to bind on ports lower than 1024.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        # Restart server on any problem.
        Restart = "on-failure";
        # ... Unless it is a configuration problem.
        RestartPreventExitStatus = 2;
      };
    };
  };
}
