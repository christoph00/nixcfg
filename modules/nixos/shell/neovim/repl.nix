{flake, lib, pkgs, config, ...}:
let
  inherit (lib) mkIf;
in 
  {
  config = mkIf config.programs.nvf.enable  {

    programs.nvf.settings.vim.extraPlugins.yarpl = {
      package = pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "yarpl.nvim";
        version ="0.11.0";
        src = pkgs.fetchFromGitHub{
          owner = "milamglacier";
          repo = "yarpl.nvim";
          rev = "v${version}";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };
      setup = ''
        local yarpl = reqire "yarpl"
        yarpl.setup {
         scratch = true,
         ft = "REPL",
         metas = {
         zsh = { cmd = "zsh", formatter = "bracketed_pating" source_syntax = "bash" },
         },
        }

      '';

    };

  };
}

