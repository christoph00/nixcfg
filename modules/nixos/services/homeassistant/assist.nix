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
  cfg = config.internal.services.homeassistant;

in

{


  config = mkIf cfg.enable {

    services.wyoming = {
      piper.servers.piper = {
        enable = true;
        voice = "de_DE-kerstin-low";
        speaker = 3;
        uri = "tcp://127.0.0.1:10200";
      };

      faster-whisper.servers.whisper = {
        enable = true;
        model = "base";
        language = "de";
        beamSize = 5;
        uri = "tcp://127.0.0.1:10300";
      };

      openwakeword = {
        enable = true;
        preloadModels = [
          "alexa"
          "hey_jarvis"
        ];
        uri = "tcp://127.0.0.1:10400";
      };
    };
  };

}
