{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  chr.desktop.wayfire.shell.settings = lib.mkIf config.chr.desktop.wayfire.shell.enable {
    background = {
      image = "~/Bilder/Wallpaper";
    };
  };
}
