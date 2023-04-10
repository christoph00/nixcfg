{
  pkgs,
  inputs,
  lib,
  ...
}: {
  programs.hyprland.enable = lib.mkDefault true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.default;
}
