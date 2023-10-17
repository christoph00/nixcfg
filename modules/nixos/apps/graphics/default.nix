{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.office;
in {
  options.chr.apps.office = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.packages = with pkgs; [
          libreoffice-qt
        ];
      };
    };
  };
}
