{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.waybar;
in {
  options.chr.desktop.waybar = with types; {
    enable = mkBoolOpt false "Whether or not enable waybar.";
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            position = "top";
            height = 30;
            layer = "top";
            modules-left = [
              "wlr/workspaces"
            ];
            modules-right = [
              "network"
              "pulseaudio"
              "battery"
              "tray"
              "clock"
            ];
            "wlr/workspaces" = {
              on-click = "activate";
            };
          };
        };
      };
    };
  };
}
