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
  cfg = config.internal.graphical.gaming;
  username = "christoph";
in
{

  options.internal.graphical.gaming = {
    enable = mkBoolOpt config.internal.isDesktop "Enable the Gaming.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.heroic
      pkgs.sunshine
      pkgs.protonplus
      pkgs.cartridges
      # pkgs.lutris
      (pkgs.bottles.override {
        extraLibraries =
          pkgs: with pkgs; [
            giflib
            libpng
            gnutls
            mpg123
            openal
            v4l-utils
            libpulseaudio
            libgpg-error
            alsa-plugins
            alsa-lib
            libjpeg
            sqlite
            xorg.libXcomposite
            xorg.libXinerama
            libgcrypt
            ncurses
            ocl-icd
            libxslt
            libva
            gtk3
            jansson
            vulkan-loader
          ];
      })

    ];

    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraLibraries =
            pkgs: with pkgs; [
              xz
              openssl
            ];
        };
      };
      gamescope = {
        enable = true;
        # capSysNice = true;
        package = pkgs.gamescope_git;
      };

      gamemode.enable = true;
      protontricks.enable = true;
    };

  };

}
