{
  pkgs,
  flake,
  lib,
  config,
  options,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.desktop;
in {
  config = mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    environment.systemPackages = with pkgs; [
      brightnessctl
      gammastep
      wlsunset

      _7zz
      # _7zz-rar

      desktop-file-utils

      wev
      walker

      font-manager
      file-roller
      unrar

      nautilus

      neovide

      phinger-cursors
      # chicago95
      adw-gtk3

      #nwg-look
      adwaita-icon-theme
      adwaita-qt

      moonlight-qt

      vscode

      gohufont
    ];
  };
}
