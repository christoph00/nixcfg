{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.sftpgo;
  format = pkgs.formats.json {};
  configFile = format.generate "config.json" cfg.settings;
  defaultUser = "sftpgo";
  defaultGroup = defaultUser;
in {
  options = {
    services.sftpgo = {
      enable = mkEnableOption "sftpgo";
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open ports in the firewall for sftpgo.
        '';
      };
      user = mkOption {
        type = types.str;
        default = defaultUser;
        example = "yourUser";
        description = mdDoc ''
          The user to run sftpgo as.
          By default, a user named `${defaultUser}` will be created whose home
          directory is [dataDir](#opt-services.sftpgo.dataDir).
        '';
      };

      group = mkOption {
        type = types.str;
        default = defaultGroup;
        example = "yourGroup";
        description = mdDoc ''
          The group to run sftpgo under.
          By default, a group named `${defaultGroup}` will be created.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sftpgo;
        defaultText = literalExpression "pkgs.sftpgo";
        description = mdDoc ''
          Which SFTPGo package to use.
        '';
      };

      settings = mkOption {
        type = format.type;
        description = lib.mdDoc ''
            Sftpgo config
          `${configFile}`
        '';
        default = {};
      };
      tls = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          to be configured via [](#opt-security.acme.certs).
        '';
      };
      domain = mkOption {
        type = types.str;
        example = "dav.example.com";
        description = lib.mdDoc "Domain for webdav.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/sftpgo";
        example = "/home/yourUser";
        description = lib.mdDoc ''
          The path where sftpgo data will exist.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [2022 8080];
    };
    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        uid = 256;
        description = "sftpgo daemon user";
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup}.gid =
        256;
    };
    systemd.services.sftpgo = {
      description = "Fully featured and highly configurable SFTP server";
      wants = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sftpgo serve --config-file ${configFile}";
        User = cfg.user;
        Group = cfg.group;

        WorkingDirectory = "${cfg.dataDir}";
        StateDirectory = "sftpgo";

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
