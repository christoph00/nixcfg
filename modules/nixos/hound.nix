{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.r505.hound;
  format = pkgs.formats.json {};
  configFile = format.generate "config.json" cfg.settings;
in {
  options = {
    r505.hound = {
      enable = mkEnableOption "hound";
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open ports in the firewall for Hound.
        '';
      };
      settings = mkOption {
        type = format.type;
        description = lib.mdDoc ''
            Hound config
          `${configFile}`
        '';
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [6080];
    };
    systemd.services.hound = {
      description = "Hound Code Server";
      wants = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        WorkingDirectory = "/nix/persist/hound";
        RuntimeDirectory = "hound";
        StateDirectory = "hound";
        LogsDirectory = "hound";
        ExecStart = "${pkgs.hound}/bin/houndd -conf ${configFile}";
        DynamicUser = true;

        # Strict sandboxing. You have no reason to trust code written by strangers from GitHub.
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectControlGroups = true;

        # Additional sandboxing. You need to disable all of these options
        # for privileged helper binaries (for system auth) to work correctly.
        NoNewPrivileges = true;
        PrivateDevices = true;
        RestrictSUIDSGID = true;
        ProtectKernelModules = true;
        MemoryDenyWriteExecute = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;

        # Graceful shutdown with a reasonable timeout.
        TimeoutStopSec = "7s";
        KillMode = "mixed";
        KillSignal = "SIGTERM";

        # Required to bind on ports lower than 1024.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        # Restart server on any problem.
        Restart = "on-failure";
        # ... Unless it is a configuration problem.
        RestartPreventExitStatus = 2;

        ExecReload = [
          "${pkgs.utillinux}/bin/kill -USR1 $MAINPID"
          "${pkgs.utillinux}/bin/kill -USR2 $MAINPID"
        ];
      };
    };
  };
}
