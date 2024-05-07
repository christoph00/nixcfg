{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.zathura;
in {
  options.chr.apps.zathura = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.zathura = {
          enable = true;
          options = {
            default-bg = "#000000";
            default-fg = "#FFFFFF";
          };
          # config defaults: https://git.pwmt.org/pwmt/zathura/-/blob/develop/zathura/config.c
          mappings = {
            D = "toggle_page_mode";
          };
        };
      };
    };
  };
}
