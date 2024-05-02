{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.desktop.waybar;
in
{
  options.chr.desktop.waybar = with types; {
    enable = mkBoolOpt false "Whether or not enable waybar.";
    package = mkOption {
      type = package;
      default = pkgs.waybar;
    };
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      programs.waybar = {
        package = cfg.package;
        enable = true;
        settings = {
          mainBar = {
            position = "bottom";
            height = 30;
            layer = "top";
            modules-left = [
              "wlr/workspaces"

              "wlr/taskbar"
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
