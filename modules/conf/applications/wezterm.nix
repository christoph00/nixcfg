{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.conf.applications.wezterm;
in {
  options.conf.applications.wezterm.enable = lib.mkEnableOption "Wezterm";
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.conf.users.user} = {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require 'wezterm'
          scheme, metadata = wezterm.color.load_base16_scheme("${config.scheme.outPath}")
          return {
            hide_tab_bar_if_only_one_tab = true,
            colors = scheme,
            font = wezterm.font '${config.conf.fonts.monospace.name}',
            font_size = 13.0,
          }
        '';
      };
    };
  };
}
