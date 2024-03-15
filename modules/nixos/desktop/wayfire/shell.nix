{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  iconSize = 24;
in {
  chr.desktop.wayfire.shellSettings = lib.mkIf config.chr.desktop.wayfire.enable {
    dock = {
      autohide = true;
    };
    panel = {
      battery_icon_size = iconSize;
      volume_icon_size = iconSize;
    };
  };
}
