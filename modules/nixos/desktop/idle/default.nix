{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.idle;
  lockCommand = "${pkgs.waylock}/bin/waylock -fork-on-lock";
in {
  options.chr.desktop.idle = with types; {
    enable = mkBoolOpt' config.chr.desktop.hyprland.enable;
  };

  config.chr.home.extraOptions = lib.mkIf cfg.enable {
    home.packages = [pkgs.gtklock];
    services.swayidle = {
      enable = true;
      extraArgs = ["-d"];
      systemdTarget = "hyprland-session.target";
      timeouts = [
        {
          timeout = 2400;
          command = "hyprctl dispatch dpms off";
          resumeCommand = "hyprctl dispatch dpms on";
        }
        {
          timeout = 3600;
          command = "systemctl hybrid-sleep";
        }
        {
          timeout = 180;
          command = lockCommand;
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = lockCommand;
        }
        # { event = "after-resume"; command = "hyprctl dispatch dpms on"; }
      ];
    };
  };
}
