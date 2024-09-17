{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    optional
    asserts
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.waybar;

  workspaces = {
    format = "{id}";
    on-click = "activate";
  };

  mainWaybarConfig = {
    layer = "top";
    gtk-layer-shell = true;
    height = 14;
    position = "bottom";

    modules-left = ["wlr/workspaces" "wlr/taskbar"];
    modules-right = [
      "clock"
      "disk"
      "cpu"
      "cpu#cores"
      "memory"
      "temperature"
      "pulseaudio"
      "battery"
      "bluetooth"
      "network"
      "tray"
    ];

    "wlr/workspaces" = workspaces;
    "wlr/taskbar" = workspaces;

  };

in
{
  options.profiles.internal.desktop.waybar = with types; {
    enable = mkBoolOpt config.profiles.internal.desktop.wayfire.enable "Enable Waybar Desktop";

  };

  config.programs.waybar = mkIf cfg.enable {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    settings = {
      mainBar = mainWaybarConfig;
    };
    style = ./style.css;
  };
}
