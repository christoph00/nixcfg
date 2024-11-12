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
  cfg = config.internal.graphical.desktop.labwc;
in
{

  options.internal.graphical.desktop.labwc = {
    enable = mkBoolOpt false "Enable the labwc desktop environment.";
  };

  config = mkIf cfg.enable {

    programs.labwc.enable = true;
    environment.systemPackages = with pkgs; [
      labwc-gtktheme
      labwc-tweaks-gtk
      labwc-menu-generator
    ];

    programs.uwsm = {
      enable = true;
      waylandCompositors.labwc = {
        binPath = "/run/current-system/sw/bin/labwc";
        prettyName = "labwc";
        comment = "Labwc managed by UWSM";
      };
    };

  };

}
