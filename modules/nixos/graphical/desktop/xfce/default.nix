{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.desktop.xfce;
in
{

  options.internal.graphical.desktop.xfce = {
    enable = mkBoolOpt false "Enable the Cosmic desktop environment.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        blueman
        picom
        wmctrl
        xclip
        xcolor
        xcolor
        xdo
        xdotool
        xfce.catfish
        xfce.gigolo
        xfce.orage
        xfce.xfburn
        xfce.xfce4-appfinder
        xfce.xfce4-clipman-plugin
        xfce.xfce4-cpugraph-plugin
        xfce.xfce4-dict
        xfce.xfce4-fsguard-plugin
        xfce.xfce4-genmon-plugin
        xfce.xfce4-netload-plugin
        xfce.xfce4-panel
        xfce.xfce4-pulseaudio-plugin
        xfce.xfce4-systemload-plugin
        xfce.xfce4-weather-plugin
        xfce.xfce4-whiskermenu-plugin
        xfce.xfce4-xkb-plugin
        xfce.xfdashboard
        xorg.xev
        xsel
        xtitle
        xwinmosaic
        zuki-themes
      ];
    };

    programs = {
      dconf.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-media-tags-plugin
          thunar-volman
        ];
      };
    };

    security.pam.services.gdm.enableGnomeKeyring = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services = {
      blueman.enable = true;

      xserver = {
        enable = true;
        excludePackages = with pkgs; [
          xterm
        ];

        desktopManager.xfce.enable = true;
      };
    };

  };

}
