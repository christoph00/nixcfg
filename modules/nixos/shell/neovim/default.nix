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
    enable = mkBoolOpt true "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {

    programs.nvf = {
      enable = true;

      settings.vim = {
        viAlias = false;
        vimAlias = false;
        enableLuaLoader = true;
        preventJunkFiles = true;
        tabWidth = 4;
        autoIndent = true;
        cmdHeight = 1;
        useSystemClipboard = true;
        mouseSupport = "a";
        scrollOffset = 6;

        telescope.enable = true;

        autopairs.enable = true;

        notes = {
          todo-comments.enable = true;
        };

        utility = {
          surround.enable = true;
        };

        theme = {
          enable = true;
          name = "tokyonight";
          transparent = false;
          style = "night";
        };

        dashboard.startify.enable = true;

        maps = {
          normal = {
            "<leader>v" = {
              action = "<CMD>Neotree toggle<CR>";
              silent = true;
            };
            "<leader>m" = {
              action = "<CMD>MarkdownPreviewToggle<CR>";
              silent = true;
            };
          };

          terminal = {
            # get out of terminal mode in toggleterm
            "<ESC>" = {
              action = "<C-\\><C-n>";
              silent = true;
            };
          };
        };

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
          context.enable = true;
          highlight.enable = true;
          indent.enable = true;
          addDefaultGrammars = false; # cuz its broken rn
        };

        autocomplete = {
          enable = true;
          alwaysComplete = false;
        };

        ui = {
          noice.enable = true;
        };

        visuals = {
          enable = true;
          indentBlankline = {
            enable = true;
            #          eolChar = null;
            #fillChar = null;
          };
          highlight-undo.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        terminal.toggleterm = {
          enable = true;
          setupOpts.direction = "tab";
          mappings.open = "<C-\\>";
        };

        git = {
          enable = true;
          gitsigns = {
            enable = false;
          };
        };

        lsp = {
          enable = true;
          lspSignature.enable = true;
          lspconfig.enable = true;
          lsplines.enable = true;
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
