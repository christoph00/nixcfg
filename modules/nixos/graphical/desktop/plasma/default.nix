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
  cfg = config.internal.graphical.desktop.plasma;
in
{

  options.internal.graphical.desktop.plasma = {
    enable = mkBoolOpt false "Enable the KDE Plasma desktop environment.";
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = [ pkgs.kdePackages.kde-gtk-config ];

    environment.plasma6.excludePackages = with pkgs; [
      oxygen
      plasma-browser-integration
    ];

    chaotic.appmenu-gtk3-module.enable = true;

  };

}
