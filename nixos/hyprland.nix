{
  pkgs,
  inputs,
  lib,
  ...
}: {
  programs.hyprland.enable = lib.mkDefault true;
  programs.hyprland.package = pkgs.hyprland;
}
