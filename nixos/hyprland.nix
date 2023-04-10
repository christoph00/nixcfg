{
  pkgs,
  inputs,
  lib,
  ...
}: {
  programs.hyprland.enable = lib.mkDefault true;
  # programs.hyprland.package = inputs.hyprland.packages.x86_64-linux.default;
}
