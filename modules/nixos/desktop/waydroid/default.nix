{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.media;
in {
  options.chr.desktop.waydroid = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Enable Waydroid.";
  };
  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [
        {
          directory = "/var/lib/waydroid";
        }
      ];
    };
  };
}
