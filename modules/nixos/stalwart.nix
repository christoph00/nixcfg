{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.stalwart;
  yaml = pkgs.formats.yaml {};
  toml = pkgs.formats.toml {};
  jmapConfig = yaml.generate "config-jmap.yaml" cfg.jmap.settings;
  imapConfig = yaml.generate "config-imap.yaml" cfg.imap.settings;
  smptConfig = toml.generate "config-smtp.toml" cfg.smtp.settings;
  defaultUser = "stalwart";
  defaultGroup = defaultUser;
in {
  options = {
    services.stalwart = {
      enable = mkEnableOption "stalwart";
      user = mkOption {
        type = types.str;
        default = defaultUser;
        example = "yourUser";
        description = mdDoc ''
          The user to run stalwart as.
        '';
      };

      group = mkOption {
        type = types.str;
        default = defaultGroup;
        example = "yourGroup";
        description = mdDoc ''
          The group to run stalwaert under.
        '';
      };
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open ports in the firewall for stalwart.
        '';
      };
      jmap = {
        enable = mkEnableOption "stalwart-jmap";

        settings = mkOption {
          type = yaml.type;
          description = lib.mdDoc ''
              stalwart jmap config
            `${jmapConfig}`
          '';
          default = {};
        };
      };
      imap = {
        enable = mkEnableOption "stalwart-imap";

        settings = mkOption {
          type = yaml.type;
          description = lib.mdDoc ''
              stalwart imap config
            `${imapConfig}`
          '';
          default = {};
        };
      };
      smtp = {
        enable = mkEnableOption "stalwart-smtp";

        settings = mkOption {
          type = toml.type;
          description = lib.mdDoc ''
              stalwart smtp config
            `${smtpConfig}`
          '';
          default = {
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [25];
    };
    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        description = "stalwart user";
        isSystemUser = true;
        group = cfg.group;
      };
    };
    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = {};
    };

    environment.systemPackages = [pkgs.stalwart-cli];

    systemd.services.stalwart-jmap = mkIf cfg.jmap.enable {
      description = "stalwart jmap server";
      wants = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.stalwart-jmap}/bin/stalwart-jmap --config=${jmapConfig}";
        User = cfg.user;

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
        #AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        Restart = "on-failure";
        RestartPreventExitStatus = 2;
      };
    };
    systemd.services.stalwart-imap = mkIf cfg.imap.enable {
      description = "stalwart imap server";
      wants = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      requires = ["imap.socket"];
      serviceConfig = {
        ExecStart = "${pkgs.stalwart-imap}/bin/stalwart-imap --config=${imapConfig}";
        User = cfg.user;

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
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        Restart = "on-failure";
        RestartPreventExitStatus = 2;
      };
    };
    systemd.sockets.imap = {
      listenStreams = ["0.0.0.0:993"];
    };
  };
}
