{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./firefox.nix ./wezterm.nix ./helix.nix ./vscode.nix ./kitty.nix ./office.nix];
}
