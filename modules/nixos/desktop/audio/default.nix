{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.audio;
in {
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];
  options.chr.desktop.audio = with types; {
    enable = mkOpt types.bool (config.chr.desktop.enable) "Whether to enable Audio Config.";
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      lowLatency = {
        # enable this module
        enable = config.chr.gameing.enable;
        # defaults (no need to be set unless modified)
        quantum = 64;
        rate = 48000;
      };
    };

    # make pipewire realtime-capable
    security.rtkit.enable = true;
  };
}
