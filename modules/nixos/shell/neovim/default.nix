{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell.neovim;
in
{
  options.internal.shell.neovim = with types; {
    enable = mkBoolOpt false "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      settings = {
        vim = {
          useSystemClipboard = true;

          options = {
            # 2-space indents
            tabstop = 2;
            softtabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            autoindent = true;
            smartindent = true;
            breakindent = true;

            # Searching
            hlsearch = true;
            incsearch = true;
            ignorecase = true;
            smartcase = true;

            # Splitting
            splitbelow = true;
            splitright = true;

            # Undo
            undofile = true;
            undolevels = 10000;
            swapfile = false;
            backup = false;

            # Disable folding
            foldlevel = 99;
            foldlevelstart = 99;

            # Misc
            termguicolors = true;
            timeoutlen = 1000;
            scrolloff = 4;
            sidescrolloff = 4;
            cursorline = true;
            encoding = "utf-8";
            fileencoding = "utf-8";
            fillchars = "eob: "; # Disable the "~" chars at end of buffer
          };

          mini = {
            icons.enable = true;
            statusline.enable = true;
            tabline.enable = true;
            git.enable = true;
            diff.enable = true;
            align.enable = true;
            notify.enable = true;
            files.enable = true;
          };

          theme = {
            enable = true;
            name = "tokyonight";
            transparent = false;
            style = "day";
          };

          autocomplete.blink-cmp = {
            enable = true;
            setupOpts = {
              signature.enabled = true;
              keymap.preset = "enter";
              sources = {
                default = [
                  "lsp"
                  "path"
                  "snippets"
                  "buffer"
                  # "copilot"
                ];
              };

            };
          };

          languages = {
            # Options applied to all languages
            enableLSP = true;
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;
            enableDAP = true;

            # Languages
            nix = {
              enable = true;
              format = {
                type = "nixfmt";
                package = pkgs.nixfmt-rfc-style;
              };
              lsp = {
                enable = true;
                server = "nixd";
              };
              treesitter.enable = true;
            };
            go.enable = true;
            php.enable = true;
          };
          lsp = {
            formatOnSave = true;
            # lspkind.enable = true;
            trouble.enable = true;
            lspSignature.enable = false;
            otter-nvim.enable = true;
          };

          treesitter = {
            enable = true;
            addDefaultGrammars = true;
            autotagHtml = true;
            # Maybe just install every single one?
            grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              yaml # Affects obsidian note frontmatter
              latex
              nix
              php
            ];
          };
        };
      };
    };
  };
}
