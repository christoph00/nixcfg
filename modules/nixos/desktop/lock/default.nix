{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.lock;
in {
  options.chr.desktop.lock = with types; {
    enable = mkBoolOpt' config.chr.desktop.hyprland.enable;
  };

  config = {
    security.pam.services.hyprlock.text = "auth include login";

    chr.home.extraOptions = lib.mkIf cfg.enable {
      programs.hyprlock = {
        enable = true;

        general.hide_cursor = false;
      };
    };
  };
}
