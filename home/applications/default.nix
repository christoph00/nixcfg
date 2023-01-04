{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./firefox.nix ./wezterm.nix ./helix.nix ./vscode.nix];
}
