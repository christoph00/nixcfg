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
  cfg = config.internal.graphical.desktop.wayland;
  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          swayidle = {
            basePackage = pkgs.swayidle;
            flags = [
              "-w"
              "timeout"
              "300"
              "gtklock"
              "timeout"
              "600"
              "wlr-randr --output eDP-1 --off"
              "before-sleep"
              "gtklock"
            ];
          };
        };
      }
    ];
  };
in
{

  options.internal.graphical.desktop.wayland = {
    enable = mkBoolOpt false "Enable the wayland environment.";
    waybar = mkBoolOpt true "Enable Waybar";
    sfwbar = mkBoolOpt false "Enable sfwbar";
    ironbar = mkBoolOpt false "Enable ironbar";
    xsettingsd = mkBoolOpt false "Enable xsettingsd";
    uwsm = mkBoolOpt true "Enable uwsm";
    wlsunset = mkBoolOpt config.internal.isLaptop "Enable wlsunset";

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
      #wlr.enable = true;
      #extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    programs.uwsm = {
      enable = cfg.uwsm;
      waylandCompositors = {
        # niri = {
        #   prettyName = "Niri";
        #   comment = "A scrollable-tiling Wayland compositor.";
        #   binPath = "${pkgs.niri}/bin/niri";
        # };
        # labwc = {
        #   prettyName = "Labwc";
        #   comment = "A Wayland window-stacking compositor.";
        #   binPath = "${pkgs.labwc}/bin/labwc";
        # };
      };
    };

    systemd.user.services = mkIf cfg.uwsm {
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
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.sfwbar}/bin/sfwbar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "app-graphical.slice";

      };
      ironbar = mkIf cfg.ironbar {
        description = "ironbar";
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.ironbar}/bin/ironbar";
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

      wlsunset = mkIf cfg.wlsunset {
        description = "wlsunset";
        script = "${pkgs.wlsunset}/bin/wlsunset";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };

      # xsettingsd = mkIf cfg.xsettingsd {
      #   description = "xsettingsd";
      #   script = "${pkgs.xsettingsd}/bin/xsettingsd";
      #   wantedBy = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig.Slice = "background-graphical.slice";
      # };

      xfce-power-manager = mkIf cfg.xsettingsd {
        description = "xfce-power-manager";
        script = "${pkgs.xfce.xfce4-power-manager}/bin/xfce4-power-manager";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };

      #   polkit-gnome-authentication-agent-1 = {
      #     description = "polkit-gnome-authentication-agent-1";
      #     script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      #     wantedBy = [ "graphical-session.target" ];
      #     after = [ "graphical-session.target" ];
      #     serviceConfig.Slice = "background-graphical.slice";
      #   };
    };

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
    #security.pam.services.waylock = { };

    environment.systemPackages = with pkgs; [

      wrapped
      #xwayland
      #wayland-protocols
      #wayland-utils
      wl-clipboard
      #wlroots
      wlr-randr
      #waylock
      wayvnc
      wlogout
      lswt
      wlrctl
      #wlopm
      wev

      rofi-wayland

      #grim

      gtklock

      swww

      #fuzzel

      #waybar
      sysmenu

      #sfwbar

      uwsm

      pwvucontrol

      #gtk4-layer-shell
      #internal.hyprpanel

      #mako
      # swayidle

      #wtype

      #swayimg
      wlr-randr
      wl-clipboard

      #wluma
      #wl-mirror
      #wf-recorder

      libnotify

      #xsettingsd

    ];

  };

}
