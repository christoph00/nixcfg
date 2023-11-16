{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.kitty;
in {
  options.chr.apps.kitty = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.kitty = {
          enable = true;
          theme = "Afterglow";
          settings = {
            confirm_os_window_close = 0;
          };
        };
      };
    };
  };
}
