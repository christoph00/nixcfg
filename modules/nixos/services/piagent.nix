{
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (flake.lib) mkStrOpt;

  cfg = config.svc.piagent;

  # Workspace-Pfad und User-Konfiguration
  workspacePath = "/var/lib/piagent/clippy/workspace";
  piagentUser = "piagent";
  clippyUser = "christoph";  # Original User für Workspace-Verweise

  # Symlinks zu Extensions, Skills, etc.
  extensionsSource = "/home/${clippyUser}/Code/pi-aivena/extensions";
  piAgentExtensions = "/var/lib/piagent/.pi/extensions";
  piAgentSkills = "/var/lib/piagent/.pi/skills";
  piAgentMemory = "/var/lib/piagent/.pi/memory";
in
{
  options.svc.piagent = {
    enable = mkEnableOption "Enable piagent (Clippy) service";
    user = mkStrOption {
      type = types.str;
      default = piagentUser;
      description = "User to run piagent as";
    };
    workspace = mkStrOption {
      type = types.str;
      default = workspacePath;
      description = "Workspace directory for piagent";
    };
    extensionsPath = mkStrOption {
      type = types.str;
      default = extensionsSource;
      description = "Path to pi extensions source";
    };
  };

  config = mkIf cfg.enable {
    # piagent User erstellen
    users.users.${piagentUser} = {
      isSystemUser = true;
      group = piagentUser;
      description = "Pi AI Agent - Clippy instance";
      home = "/var/lib/piagent";
      shell = pkgs.bash;
      createHome = true;
    };

    # piagent Group erstellen
    users.groups.${piagentUser} = {};

    # Workspace-Verzeichnis erstellen
    systemd.tmpfiles.rules = [
      "d ${workspacePath} 0750 ${piagentUser} ${piagentUser} -"
      "d ${piAgentExtensions} 0755 ${piagentUser} ${piagentUser} -"
      "d ${piAgentSkills} 0755 ${piagentUser} ${piagentUser} -"
      "d ${piAgentMemory} 0750 ${piagentUser} ${piagentUser} -"
    ];

    # Systemd Service - gehärtet
    systemd.services.piagent = {
      description = "Pi AI Agent - Clippy instance";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
      ];
      wants = [
        "network-online.target"
      ];
      path = with pkgs; [
        nodejs
        python3
        git
        bashInteractive
        coreutils
        curl
        wget
      ];
      script = ''
        cd ${workspacePath}
        exec node node_modules/.bin/pi --chat-bridge --cron --heartbeat
      '';
      serviceConfig = {
        # User und Gruppe
        User = piagentUser;
        Group = piagentUser;

        # Restart-Policy
        Restart = "always";
        RestartSec = 30;
        StartLimitInterval = 300;
        StartLimitBurst = 5;

        # Working Directory
        WorkingDirectory = workspacePath;

        # Security Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          workspacePath
          piAgentExtensions
          piAgentSkills
          piAgentMemory
          "/var/lib/piagent"
        ];

        # Network-Isolation (optional, je nach Bedarf)
        # PrivateNetwork = false;  # Set true wenn kein Internet nötig

        # Environment
        Environment = [
          "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin"
          "NODE_ENV=production"
        ];

        # Logging
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "piagent";

        # Ressourcen-Limits
        MemoryMax = "512M";
        CPUQuota = "50%";

        # Sicherheit: Exec-Verzeichnisse schützen
        ExecStartPre = pkgs.writeShellScript "piagent-setup" ''
          # Symlinks zu Extensions erstellen (wenn noch nicht vorhanden)
          if [ ! -L ${piAgentExtensions} ]; then
            ln -sf ${extensionsSource} ${piAgentExtensions}
            echo "✓ Extensions symlink created"
          fi

          # Workspace prüfen
          if [ ! -f ${workspacePath}/.pi/settings.json ]; then
            echo "⚠️  Workspace nicht vorbereitet: ${workspacePath}"
            echo "Bitte Workspace von ${clippyUser} kopieren oder initialisieren"
            exit 1
          fi
        '';
      };
    };

    # Optional: Log-Rotation für piagent
    services.logrotate.settings.piagent = {
      files = "/var/log/piagent/*.log";
      rotate = 7;
      weekly = true;
      compress = true;
      missingok = true;
      notifempty = true;
    };
  };
}
