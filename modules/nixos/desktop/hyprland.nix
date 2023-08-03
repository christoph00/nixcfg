{
  config,
  lib,
  inputs',
  ...
}: let
  inherit (lib) mkIf;
in {
  # disables Nixpkgs Hyprland module to avoid conflicts
  disabledModules = ["programs/hyprland.nix"];

  config = mkIf (builtins.elem config.nos.type ["desktop" "laptop"] && (config.desktop.wm == "Hyprland")) {
    services.xserver.displayManager.sessionPackages = [inputs'.hyprland.packages.default];

    xdg.portal = {
      extraPortals = [
        (inputs'.xdg-portal-hyprland.packages.xdg-desktop-portal-hyprland.override {
          hyprland-share-picker = inputs'.xdg-portal-hyprland.packages.hyprland-share-picker.override {
            hyprland = inputs'.hyprland.packages.default;
          };
        })
      ];
    };
  };
}
