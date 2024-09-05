{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

{

  config = mkIf config.internal.isGraphical {

    internal.graphical.desktop.wayfire.enable = true;
    internal.graphical.desktop.plasma.enable = true;
    hardware.graphics.enable = true;

    internal.user.extraGroups = [
      "video"
      "audio"
      "input"
      "tty"
    ];

    environment.systemPackages = with pkgs; [
      greetd.gtkgreet

      xwayland

      meson
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
    ];

    services.xserver.displayManager.startx.enable = true;

    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "KDE";
    };

    programs.dconf.enable = true;

    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        #xdg-desktop-portal
        xdg-desktop-portal-kde
        #xdg-desktop-portal-wlr

        # for Firefox cursor, fixes Vesktop?
        #xdg-desktop-portal-gtk
      ];
    };

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    fonts.packages = with pkgs; [
      noto-fonts
      meslo-lgs-nf
    ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };

}
