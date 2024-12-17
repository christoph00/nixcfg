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
      pkgs.protonup-qt
      pkgs.cartridges
      # pkgs.lutris
      pkgs.bottles
      pkgs.antimicrox
      pkgs.gamescope
      pkgs.protontricks
      pkgs.limo
      # pkgs.vkbasalt-cli
      # pkgs.vkbasalt
      # pkgs.goverlay
      pkgs.mangohud

    ];

    services.udev.packages = [ pkgs.antimicrox ];

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = false;
      openFirewall = true;
    };

    systemd.user.services = {
      sunshine = {
        path = [ config.system.path ];
        serviceConfig.Slice = "background-graphical.slice";
        after = [ "graphical-session.target" ];
      };
      gamemoded = {
        serviceConfig.Slice = "background-graphical.slice";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
      };
    };

    services.input-remapper.enable = true;

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
      # gamescope = {
      # enable = true;
      # capSysNice = true;
      # package = pkgs.gamescope_git;
      # };

      gamemode.enable = true;
      # protontricks.enable = true;
    };

  };

}
