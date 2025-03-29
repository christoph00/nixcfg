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
  cfg = config.internal.graphical.desktop.niri;
in
{

  options.internal.graphical.desktop.niri = {
    enable = mkBoolOpt config.internal.isLaptop "Enable the niri desktop environment.";
  };

  config = mkIf cfg.enable {

    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [

      networkmanagerapplet
      adwaita-icon-theme
      #greybird
      #glib
      #xfce.xfce4-panel
      #mate.mate-panel
    ];

    programs.uwsm = {
      waylandCompositors.niri = {
        binPath = "${config.programs.niri.package}/bin/niri";
        prettyName = "niri";
        comment = "niri managed by UWSM";
      };
    };

  };

}
