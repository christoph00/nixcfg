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

      font-manager
      file-roller
      unrar

      phinger-cursors
      # chicago95
      adw-gtk3

      #nwg-look
      adwaita-icon-theme
      adwaita-qt
      adwsteamgtk

    ];

  };

}
