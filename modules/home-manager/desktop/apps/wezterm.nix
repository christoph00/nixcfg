{
  config,
  pkgs,
  ...
}: let
  inherit (config) colorscheme;
  inherit (colorscheme) colors;
in {
  programs.wezterm = {
    enable = true;
    extraConfig =
      /*
      lua
      */
      ''
        return {
          font_size = 12.0,
          color_scheme = 'tokyonight-day',
          hide_tab_bar_if_only_one_tab = true,
          window_close_confirmation = "NeverPrompt",
          set_environment_variables = {
            TERM = 'wezterm',
          },
          window_background_opacity = 1,
        }
      '';
  };
}
