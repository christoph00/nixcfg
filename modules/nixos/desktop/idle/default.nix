{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.idle;
in {
  options.chr.desktop.idle = with types; {
    enable = mkBoolOpt' config.chr.desktop.hyprland.enable;
  };

  config.chr.home.extraOptions = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = false;
      beforeSleepCmd = "${pkgs.systemd}/bin/loginctl lock-session";
      #lockCmd = lib.getExe config.programs.hyprlock.package;
      lockCmd = "hyprlock";

      listeners = [
        {
          timeout = 330;
          onTimeout = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
