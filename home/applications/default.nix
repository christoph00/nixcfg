{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./firefox.nix ./wezterm.nix];
}
