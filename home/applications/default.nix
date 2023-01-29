{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./firefox.nix
    ./helix.nix
    ./chromium.nix
    #./vscode.nix
    ./kate.nix
    ./office.nix
    ./discord.nix
    ./kdeconnect.nix
    ./nemo.nix
    ./foot.nix
    ./obsidian.nix
    ./geary.nix
  ];
}
