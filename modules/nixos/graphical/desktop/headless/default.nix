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

let
  cfg = config.internal.graphical.desktop.headless;
in
{

  options.internal.graphical.desktop.headless = {
    enable = mkBoolOpt false "Enable Headless Desktop.";
    autorun = mkBoolOpt true "Autorun";
    user = mkOption {
      type = types.str;
      default = "christoph";

    };
  };

  config = mkIf cfg.enable {

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
        '';

    environment.sessionVariables = {
      WLR_BACKENDS = "drm,headless,libinput";
      NIXOS_OZONE_WL = "1";
      WAYLAND_DISPLAY = "wayland-1";
      #WLR_LIBINPUT_NO_DEVICES = "1";
      WLR_RENDERER = "pixman";
      #XDG_RUNTIME_DIR="/tmp";
      XDG_RUNTIME_DIR = "/run/user/1000";
      WLR_RENDER_DRM_DEVICE = "/dev/dri/card0";

    };
    services.xserver.autorun = false;
    services.graphical-desktop.enable = true;

    services.seatd.enable = true;

    users.extraUsers."${cfg.user}".linger = mkDefault true;

  };

}
