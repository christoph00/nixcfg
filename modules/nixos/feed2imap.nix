{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.feed2imap;
in {
  options = {
    services.feed2imap = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable feed2imap.";
      };

      interval = mkOption {
        type = types.str;
        default = "4h";
        description = lib.mdDoc "How often to check the feeds, in systemd interval format";
      };

      configFile = mkOption {
        type = types.str;
        default = "example.yml";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/feed2imap";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    users.users.feed2imap = {
      description = "feed2imap user";
      group = "feed2imap";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    environment.systemPackages = with pkgs; [feed2imap-go];

    systemd.services.feed2imap = {
      serviceConfig = {
        ExecStart = "${pkgs.feed2imap-go}/bin/feed2imap-go -f ${configFile} -c feeds.cache";
        User = "feed2imap";
        Group = "feed2imap";
        WorkingDirectory = "${cfg.dataDir}";
        StateDirectory = "feed2imap";
      };
    };

    systemd.timers.feed2imap = {
      partOf = ["feed2imap.service"];
      wantedBy = ["timers.target"];
      timerConfig.OnBootSec = "0";
      timerConfig.OnUnitActiveSec = cfg.interval;
    };
  };
}
