{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.nvf.enable {

    programs.nvf.settings.vim.extraPlugins.yarepl = {
      package = pkgs.vimUtils.buildVimPlugin rec {
        pname = "yarepl.nvim";
        version = "0.11.0";
        src = pkgs.fetchFromGitHub {
          owner = "milanglacier";
          repo = "yarepl.nvim";
          rev = "v${version}";
          hash = "sha256-6kl7xQpDiyuiqmjTPVbAjff+EGIVzWw/RBOaqZP3iGo=";
        };
        nvimSkipModules = [ "yarepl.extensions.fzf" ];
      };
      setup = ''
        local yarepl = require("yarepl")
        yarepl.setup({
         metas = {
                aichat = { cmd = "aichat", formatter = yarepl.formatter.bracketed_pasting },
                radian = { cmd = "radian", formatter = yarepl.formatter.bracketed_pasting },
                ipython = { cmd = "ipython", formatter = yarepl.formatter.bracketed_pasting },
                python = { cmd = "python", formatter = yarepl.formatter.trim_empty_lines },
                R = { cmd = "R", formatter = yarepl.formatter.trim_empty_lines },
                bash = { cmd = "bash", formatter = yarepl.formatter.trim_empty_lines },
                zsh = { cmd = "zsh", formatter = yarepl.formatter.bracketed_pasting },
            },
                   })

      '';

    };

  };
}
