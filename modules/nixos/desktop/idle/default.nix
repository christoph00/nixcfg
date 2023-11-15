{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.idle;
in {
  options.chr.desktop.idle = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config.services.swayidle = lib.mkIf cfg.enable {
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
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.gtklock}/bin/gtklock";
      }
      # { event = "after-resume"; command = "hyprctl dispatch dpms on"; }
    ];
  };
}
