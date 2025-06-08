{
  pkgs,
  flake,
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.desktop;
in
{
  config = mkIf cfg.enable {
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
      adwsteamgtk

    ];

    home.files.".local/share/applications/neovide-oca.desktop".text = ''
      [Desktop Entry]
      Name=Neovide OCA
      Exec=${pkgs.neovide}/bin/neovide --server 100.77.155.15:10066
      Icon=${pkgs.neovide}/share/icons/hicolor/256x256/apps/neovide.png
      Type=Application
      Categories=Development;IDE;
    '';

  };

}
