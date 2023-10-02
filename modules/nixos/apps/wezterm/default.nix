{ options, config, lib, pkgs, ... }:

with lib;
with lib.chr;
let cfg = config.chr.apps.wezterm;
in
{
  options.chr.apps.wezterm = with types; {
    enable = mkBoolOpt false "Whether to enable Wezterm.";
  };

  config = mkIf cfg.enable {
 
   programs.wezterm = {
    enable = true;
    extraConfig =
      /*
      lua
      */
      ''
        return {
          font_size = 12.0,
          color_scheme = 'Tokyo Night Light (Gogh)',
          hide_tab_bar_if_only_one_tab = true,
          window_close_confirmation = "NeverPrompt",
          set_environment_variables = {
            TERM = 'wezterm',
          },
          window_background_opacity = 1,
        }
      '';
  };
  };
}