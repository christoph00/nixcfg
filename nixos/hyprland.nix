{
  pkgs,
  config,
  lib,
  ...}: {
  programs.hyprland.enable = lib.mkDefault true;
  programs.hyprland.package = null;
}
