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

{

  config = mkIf config.internal.isGraphical {

    internal.graphical.desktop.wayland.enable = false;
    # internal.graphical.desktop.cosmic.enable = true;
    # internal.graphical.desktop.wayfire.enable = true;
    # internal.graphical.desktop.plasma.enable = true;
    internal.graphical.desktop.xfce.enable = true;
    hardware.graphics.enable = true;

    #programs.labwc.enable = true;

    internal.user.extraGroups = [
      "video"
      "audio"
      "input"
      "tty"
    ];

    environment.systemPackages = with pkgs; [

      brightnessctl
      gammastep
      wlsunset

      whitesur-gtk-theme
      whitesur-icon-theme

      (rofi.override { plugins = [ rofi-emoji ]; })

      font-manager
      file-roller
      pavucontrol

      networkmanagerapplet
      pipewire
      wireplumber

      unrar

      phinger-cursors

      kdePackages.qt6ct

      catppuccin-qt5ct

      chicago95

    ];

    gtk.iconCache.enable = true;

    services.gnome.gnome-keyring.enable = true;

    programs.dconf.enable = true;
    services = {

      xserver = {
        enable = true;
        xkb.layout = "de";
      };

      dbus.implementation = "broker";

      dbus.enable = true;

      graphical-desktop.enable = true;

      seatd.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    fonts.packages = with pkgs; [
      # chicago95
      commit-mono
      cascadia-code
      martian-mono
      pixel-code
      mona-sans
      monaspace
      hubot-sans
      maple-mono-NF
      material-design-icons
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "CascadiaCode"
          "DaddyTimeMono"
        ];
      })
    ];

  };

}
