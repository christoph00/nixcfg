{ config
, lib
, pkgs
, ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell.neovim;
in
{
  options.internal.shell.neovim = with types; {
    enable = mkBoolOpt true "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings.vim = {
        viAlias = true;
        vimAlias = true;
        enableLuaLoader = true;
        preventJunkFiles = true;
        tabWidth = 4;
        autoIndent = true;
        cmdHeight = 1;
        useSystemClipboard = true;
        mouseSupport = "a";
        scrollOffset = 6;

        extraPlugins = with pkgs.vimPlugins; {
          supermaven-nvim = {
            package = supermaven-nvim;
            setup = "require('supermaven-nvim').setup {
              disable_inline_completion = true, -- disables inline completion for use with cmp
              disable_keymaps =true, -- disables built in keymaps for more manual control
            }";
          };
          nvim-web-devicons = {
            package = nvim-web-devicons;
          };
        };

        telescope.enable = true;

        autopairs.enable = true;

        notes = {
          todo-comments.enable = true;
        };

        utility = {
          surround.enable = true;
        };


        comments = {
          comment-nvim = {
            enable = true;
          };
        };

        theme = {
          enable = true;
          name = "tokyonight";
          transparent = true;
          style = "day";
        };

        dashboard.startify.enable = true;


        filetree.neo-tree = {
          enable = true;
        };

        statusline.lualine = {
          enable = true;
          theme = "auto";
        };

        treesitter = {
          enable = true;
          fold = true;
          context.enable = false;
          highlight.enable = true;
          indent.enable = true;
          addDefaultGrammars = false;
        };

        autocomplete = {
          enable = true;
          alwaysComplete = true;

          type = "nvim-cmp";

          mappings = {
            #complete = "<Return>";
            close = "<C-e>";
            confirm = null; # set above

            scrollDocsUp = "<C-d>";
            scrollDocsDown = "<C-f>";

            next = "<Tab>";
            previous = "<S-Tab>";
          };
          sources = {
            supermaven = "[SM]";
          };

        };

        ui = {
          noice.enable = true;
          illuminate.enable = true;
          borders = {
            enable = true;
            globalStyle = "rounded";
          };
          colorizer.enable = true;
        };

        visuals = {
          enable = true;
          nvimWebDevicons.enable = true;

          indentBlankline = {
            enable = false;
            #eolChar = null;
            #fillChar = null;
          };
          highlight-undo.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        git = {
          enable = true;
        };

        terminal.toggleterm = {
          enable = true;

          mappings.open = "<c-t>";
          setupOpts = {
            winbar.enabled = false;
            direction = "float";
          };

          lazygit = {
            enable = true;
            mappings.open = "<leader>gl";
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = true;
          lightbulb.enable = false;
<<<<<<< HEAD
=======
          lspsaga.enable = false;
>>>>>>> 75e147c2 (ok)
          trouble.enable = false;
          lspSignature.enable = true;
          # lsplines.enable = true;
          lspconfig.enable = true;
          nvim-docs-view.enable = false;

          mappings = {
            addWorkspaceFolder = "<leader>wa";
            codeAction = "<leader>a";
            format = "<C-f>";
            goToDeclaration = "gD";
            goToDefinition = "gd";
            hover = "K";
            listImplementations = "gi";
            listReferences = "gr";
            listWorkspaceFolders = "<leader>wl";
            nextDiagnostic = "<leader>k";
            previousDiagnostic = "<leader>j";
            openDiagnosticFloat = "<leader>e";
            removeWorkspaceFolder = "<leader>wr";
            renameSymbol = "<leader>r";
            signatureHelp = "<C-k>";
          };
        };

        languages = {
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableLSP = true;
          enableTreesitter = true;
          bash.enable = true;
          php = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          clang = {
            enable = true;
            cHeader = true;
          };
          markdown.enable = true;
          nix = {
            enable = true;
            format.enable = true;
            format.type = "nixpkgs-fmt";
            lsp.enable = true;
            treesitter.enable = true;
          };
        };
      };
    };

  };
}
