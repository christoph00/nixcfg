{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (builtins.elem config.chr.desktop.enable && (config.chr.desktop.wm == "Hyprland")) {
    programs.hyprland = {
      enable = true;
    };
  };
}
