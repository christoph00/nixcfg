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
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = mkDefault true;

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
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
      dbus.implementation = mkDefault "broker";
      seatd.enable = true;
    };

    services.desktopManager.plasma6.enable = true;


    services.xserver.desktopManager.runXdgAutostartIfNone = true;

  };
}
