{
  pkgs,
  flake,
  lib,
  config,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.desktop;
  up = perSystem.nixpkgs-unstable;
in
{
  config = mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    programs.vscode = {
      package = up.vscode;
      enable = true;
      extensions = with up.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };

    home.packages = with up; [
      _7zz
      desktop-file-utils
      font-manager
      file-roller
      unrar
      pcmanfm
      phinger-cursors
      chicago95
      adw-gtk3
      adwaita-icon-theme
      adwaita-qt
      moonlight-qt
    ];
  };
}
