{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  inherit (flake.lib) enabled;
in {
  config.programs.nvf.settings.vim.lsp = {
    enable = true;
    formatOnSave = true;
    trouble.enable = true;
    otter-nvim.enable = true;
    lspsaga.enable = false;
    null-ls = enabled;
  };

  config.programs.nvf.settings.vim.treesitter = {
    enable = true;
    context.enable = false;
    addDefaultGrammars = true;
    autotagHtml = true;
    grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      yaml
      latex
      nix
      php
      blade
      html
      python
    ];
    textobjects = {
      enable = true;
      setupOpts.select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "a=" = "@assignment.outer";
          "i=" = "@assignment.inner";
          "l=" = "@assignment.lhs";
          "r=" = "@assignment.rhs";

          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";

          "ai" = "@conditional.outer";
          "ii" = "@conditional.inner";

          "al" = "@loop.outer";
          "il" = "@loop.inner";

          "ae" = "@call.outer";
          "ie" = "@call.inner";

          "af" = "@function.outer";
          "if" = "@function.inner";

          "ac" = "@class.outer";
          "ic" = "@class.inner";
        };
      };
    };
  };
}
