{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./firefox.nix ./helix.nix ./vscode.nix ./office.nix ./discord.nix ./kdeconnect.nix ./foot.nix];
}
