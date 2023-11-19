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
            window_padding_width = 4;
            font_style = 14;
            font_family = "IntoneMono Nerd Font Mono";
          };
          extraConfig = builtins.readFile (builtins.fetchurl {
            url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/eede574f9ef57137e6d7e4bab37b09db636c5a56/extras/kitty_tokyonight_night.conf";
            sha256 = "0l9yl3qmgf7b10x7hy7q5hma0hsyamq3n14lfbw31cimm6snwim6";
          });
        };
      };
    };
  };
}
