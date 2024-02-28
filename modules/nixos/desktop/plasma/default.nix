{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.plasma;
in {
  options.chr.desktop.plasma = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Plasma.";
  };

  config = mkIf cfg.enable {
    security.pam.services.greetd.enableKwallet = true;

    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.adwaita-icon-theme

      graphite-kde-theme
      arc-kde-theme
      adapta-kde-theme
      fluent-gtk-theme
      whitesur-gtk-theme
      whitesur-icon-theme

      fluent-icon-theme
    ];

    programs = {
      kdeconnect.enable = true;
      partition-manager.enable = true;

      # Workaround for badly themed GTK apps on Wayland
      dconf.enable = true;
    };
  };
}
