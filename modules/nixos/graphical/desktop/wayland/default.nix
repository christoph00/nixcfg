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

let
  cfg = config.internal.graphical.desktop.wayland;
in
{

  options.internal.graphical.desktop.wayland = {
    enable = mkBoolOpt false "Enable the wayland environment.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";

      __GR_VRR_ALLOWED = "0";
      __GR_GSYNC_ALLOWED = "0";
      SDL_VIDEODRIVER = "wayland";

      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_CURRENT_DESKTOP = "Hyprland";

      GDK_BACKEND = "wayland";

      _JAVA_AWT_WM_NONREPARENTING = "1";

      QT_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      DISABLE_QT5_COMPAT = "0";
      CLUTTER_BACKEND = "wayland";
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };


    environment.systemPackages = with pkgs; [
      xwayland
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
      wlr-randr
      waylock
      wayvnc
      wlogout

      ags
      bun

      swww

      waybar
      sysmenu

      # inputs.ignis.packages.${system}.ignis

      gtk4-layer-shell
      internal.hyprpanel

      ironbar

      mako
      swayidle

      wtype

      swayimg
      wlr-randr
      wl-clipboard

      wluma
      wl-mirror
      wf-recorder
    ];

  };

}
