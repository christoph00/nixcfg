{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib.chr; let
  cfg = config.chr.services.backup;
in {
  options = with lib; {
    chr.services.backup = {
      enable = mkEnableOption "Enable Backup Service";
    };
  };

  config =
    lib.mkIf cfg.enable {
    };
}
