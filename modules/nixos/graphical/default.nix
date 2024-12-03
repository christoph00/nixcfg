{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

{

  config = mkIf config.internal.isGraphical {

    internal.graphical.desktop.wayland.enable = true;
    internal.graphical.desktop.cosmic.enable = true;
    internal.graphical.desktop.labwc.enable = true;
    internal.graphical.desktop.wayfire.enable = true;
    #internal.graphical.desktop.hyprland.enable = true;
    hardware.graphics.enable = true;

    internal.user.extraGroups = [
      "video"
      "audio"
      "input"
      "tty"
    ];

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

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

      pipewire
      wireplumber

      unrar

      phinger-cursors
      # chicago95
      adw-gtk3

      nwg-look
      adwaita-icon-theme
      adwaita-qt
      adwsteamgtk

      internal.go-hass-agent

    ];

    gtk.iconCache.enable = true;

    services.gnome.gnome-keyring.enable = false;

    programs.dconf.enable = true;
    services = {

      xserver = {
        enable = false;
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
      mona-sans
      monaspace
      hubot-sans
      maple-mono-NF
      material-design-icons
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];


  };

}
