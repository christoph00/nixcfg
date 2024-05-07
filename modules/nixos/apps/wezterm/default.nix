{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.wezterm;
in {
  options.chr.apps.wezterm = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether to enable Wezterm.";
  };

  config.chr.home.extraOptions.programs.wezterm = mkIf cfg.enable {
    enable = cfg.enable;
    extraConfig = ''
      return {
        font = wezterm.font("IntoneMono Nerd Font Mono"),
        font_size = 14.0,
        --color_scheme = "Tomorrow Night",
        hide_tab_bar_if_only_one_tab = true,
      }

    '';
  };
}
