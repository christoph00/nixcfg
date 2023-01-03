{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      scheme, metadata = wezterm.color.load_base16_scheme("${config.scheme.outPath}")
      return {
        hide_tab_bar_if_only_one_tab = true,
        colors = scheme,
        font_size = 13.0,
      }
    '';
  };
}
