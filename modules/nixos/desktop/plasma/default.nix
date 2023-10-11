{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.plasma;
in {
  options.chr.desktop.plasma = with types; {
    enable = mkBoolOpt false "Whether or not to enable Plasma.";
  };

  config = mkIf cfg.enable {
    security.pam.services.greetd.enableKwallet = true;
    services.xserver.desktopManager.plasma5.enable = true;

    environment.systemPackages = with pkgs; [
      # Some missing packages for KDE Plasma desktop
      # It might change over time as packages are being added to pre-installed in nixpkgs.
      sddm-kcm
      bluedevil
      discover
      ark
      okular
      gwenview
      dolphin
      kate

      libsForQt5.accounts-qt
      libsForQt5.kaccounts-integration
      libsForQt5.kaccounts-providers
      libsForQt5.applet-window-buttons
      libsForQt5.polkit-kde-agent

      # Use GNOME's cursor to overcome this bug: https://gitlab.freedesktop.org/drm/amd/-/issues/1513
      # Forcing software curosr fixes how it looks, but introduces other glitches.
      gnome.adwaita-icon-theme

      graphite-kde-theme
      arc-kde-theme
      adapta-kde-theme
      fluent-gtk-theme
      whitesur-gtk-theme
      whitesur-icon-theme

      fluent-icon-theme

      chr.klassy

    ];

    services.dbus.packages = [pkgs.gcr];

    programs = {
      kdeconnect.enable = true;
      partition-manager.enable = true;

      # Workaround for badly themed GTK apps on Wayland
      dconf.enable = true;
    };
  };
}
