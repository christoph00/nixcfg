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
    waybar = mkBoolOpt true "Enable Waybar";
    sfwbar = mkBoolOpt false "Enable sfwbar";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";

      __GR_VRR_ALLOWED = "0";
      __GR_GSYNC_ALLOWED = "0";
      SDL_VIDEODRIVER = "wayland";

      XDG_SESSION_TYPE = "wayland";

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

    programs.uwsm = {
      enable = true;
    };

    systemd.user.services = {
      waybar = mkIf cfg.waybar {
        description = "Waybar as systemd service";
        path = [ config.system.path ];
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.waybar}/bin/waybar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "app-graphical.slice";
      };
      sfwbar = mkIf cfg.sfwbar {
        description = "sfwbar";
        script = "${pkgs.sfwbar}/bin/sfwbar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "app-graphical.slice";

      };
      swww-daemon = {
        description = "swww-daemon as systemd service";
        script = "${pkgs.swww}/bin/swww-daemon";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";

      };
      syshud = {
        description = "syshud";
        script = "${pkgs.syshud}/bin/syshud";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };
      hass-agent = {
        description = "home assistant agent";
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.internal.go-hass-agent}/bin/go-hass-agent run";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStartPre = "/run/wrappers/bin/doas systemctl stop go-hass-agent";
          Slice = "app-graphical.slice";
          ExecStop = "/run/wrappers/bin/doas systemctl start go-hass-agent";
        };
      };
      # polkit-gnome-authentication-agent-1 = {
      # description = "polkit-gnome-authentication-agent-1";
      # script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      # wantedBy = [ "graphical-session.target" ];
      # after = [ "graphical-session.target" ];
      # serviceConfig.Slice = "background-graphical.slice";
      # };
    };

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

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
      lswt
      wlrctl
      wlopm
      wev

      grim

      ags
      bun

      swww

      fuzzel

      waybar
      sysmenu
      syshud

      sfwbar

      uwsm

      pwvucontrol

      # inputs.ignis.packages.${system}.ignis

      gtk4-layer-shell
      #internal.hyprpanel

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

    security.pam.services.waylock = { };

  };

}
