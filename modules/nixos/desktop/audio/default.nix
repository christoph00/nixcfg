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
  options.chr.desktop.audio = with types; {
    enable = mkOpt types.bool config.chr.desktop.enable "Whether to enable Audio Config.";
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # make pipewire realtime-capable
    security.rtkit.enable = true;
  };
}
