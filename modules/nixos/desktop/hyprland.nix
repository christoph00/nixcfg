{
  config,
  lib,
  inputs',
  ...
}: let
  inherit (lib) mkIf;
in {
  # disables Nixpkgs Hyprland module to avoid conflicts
  #disabledModules = ["programs/hyprland.nix"];

  config = mkIf (builtins.elem config.nos.type ["desktop" "laptop"] && (config.nos.desktop.wm == "Hyprland")) {
    programs.hyprland = {
      enable = true;
      package = inputs'.hyprland.packages.default;
    };
  };
}
