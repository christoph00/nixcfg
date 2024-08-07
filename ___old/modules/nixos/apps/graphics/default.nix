{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.graphics;
in {
  options.chr.apps.graphics = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.packages = with pkgs; [
          gimp
          inkscape
          darktable
        ];
      };
    };
  };
}
