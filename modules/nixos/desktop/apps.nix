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

    programs.nm-applet.enable = false;

    home.packages = with pkgs; [
      brightnessctl
      wlsunset

      _7zz
      # _7zz-rar

      emacs-pgtk

      desktop-file-utils

      wev

      font-manager
      file-roller
      unrar

      nautilus

      neovide

      pcmanfm


      phinger-cursors
      chicago95
      adw-gtk3

      #nwg-look
      adwaita-icon-theme
      adwaita-qt

      moonlight-qt


      gohufont
    ];
  };
}
