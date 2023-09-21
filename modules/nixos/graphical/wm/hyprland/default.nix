{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (builtins.elem config.chr.type ["desktop" "laptop"] && (config.chr.desktop.wm == "Hyprland")) {
    programs.hyprland = {
      enable = true;
    };
  };
}
