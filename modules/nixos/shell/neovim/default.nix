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
    enable = mkBoolOpt config.internal.isGraphical "Whether or not to configure neovim config.";
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

        withNodeJs = false;

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
          avante-nvim = {
            package = avante-nvim;
            setup = "require('avante_lib').load()
              require('avante').setup({})";

          };
        };

        telescope.enable = true;

        autopairs.enable = true;

        notes = {
          todo-comments.enable = true;
        };

        projects = {
          project-nvim.enable = true;
        };

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          icon-picker.enable = false;
          surround.enable = true;
          diffview-nvim.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
          };

          images = {
            image-nvim.enable = false;
          };
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
          grammars = [
            (pkgs.tree-sitter.buildGrammar {
              language = "blade";
              version = "0.10.1";
              src = pkgs.fetchFromGitHub {
                owner = "EmranMR";
                repo = "tree-sitter-blade";
                rev = "335b2a44b4cdd9446f1c01434226267a61851405";
                hash = "sha256-wXzmlg79Xva08wn3NoJDJ2cIHuShXPIlf+UK0TsZdbY=";
              };
            })
          ];
        };

        autocomplete = {
          enable = true;
          alwaysComplete = true;

          type = "nvim-cmp";

          mappings = {
            complete = "<C-Space>";
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
          trouble.enable = false;
          lspSignature.enable = true;
          # lsplines.enable = true;
          lspconfig.enable = true;
          nvim-docs-view.enable = false;
          # lsplines.enable = true;
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
          tailwind.enable = true;
          html = {
            enable = true;
            treesitter.enable = true;
          };
          css.enable = true;
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
