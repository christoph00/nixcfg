{
  config,
  flake,
  lib,
  inputs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (flake.lib) mkBoolOpt;
  inherit (inputs.hjem-rum.lib.generators.environment) toEnvExport;
  cfg = config.desktop;
  up = perSystem.nixpkgs-unstable;
in
{

  options.desktop = {
    enable = mkBoolOpt false;
    waybar = mkBoolOpt false;
    wlsunset = mkBoolOpt false;
    dms = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    programs.labwc.enable = true;

    # for greeter + tools
    programs.sway.enable = true;

    hardware.graphics.enable = true;

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

    i18n.defaultLocale = "de_DE.UTF-8";

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      # ponytail: pulled in by labwc + wlr automatically
      config.common = { default = [ "gtk" "wlr" ]; };
      config.labwc = { default = [ "gtk" "wlr" ]; };
    };

    home.environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_CLASS = "user";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      GDK_BACKEND = "wayland,x11";
      MOZ_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland,x11,windows";
      CLUTTER_BACKEND = "wayland";
    };

    services = {
      dbus = { enable = true; implementation = "broker"; };
      seatd.enable = true;
    };

    programs.uwsm.enable = true;
    programs.uwsm.waylandCompositors = {
      labwc = {
        prettyName = "Labwc";
        comment = "A stacking Wayland compositor.";
        binPath = "${up.labwc}/bin/labwc";
      };
    };

    hjem.users.christoph.files.".config/uwsm/env".text =
      toEnvExport config.hjem.users.christoph.environment.sessionVariables;

    home.packages = with up; [
      labwc
      labwc-gtktheme
      labwc-tweaks-gtk
      labwc-menu-generator
      fuzzel
      foot
      brightnessctl
      clipman
      quickshell
      dms-shell
    ];

    # ponytail: exported via uwsm/env, not consumed by Hjem Rum directly
    home.rum.environment.hideWarning = true;

    programs.dms-shell = {
      enable = cfg.dms;
      package = up.dms-shell;
      enableAudioWavelength = false;
      enableVPN = false;
      quickshell.package = up.quickshell;
    };

    # ponytail: optional services, add when you actually need them
    systemd.user.services = {
      waybar = mkIf cfg.waybar {
        description = "Waybar";
        path = [ config.system.path ];
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${up.waybar}/bin/waybar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "app-graphical.slice";
      };
      wlsunset = mkIf cfg.wlsunset {
        description = "wlsunset";
        script = "${up.wlsunset}/bin/wlsunset";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };
    };

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    security.pam.services.gtklock.text = lib.readFile "${up.gtklock}/etc/pam.d/gtklock";
    security.pam.services.waylock = { };
  };
}
