{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  perSystem,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
in {
  imports = [
    inputs.nvf.nixosModules.default
    #    ./mcphub.nix
    #    ./repl.nix
    #    ./mail.nix
    #    ./notes.nix
  ];

  config = mkIf config.programs.nvf.enable {
    programs.nvf = {
      settings = {
        vim = {
          # additionalRuntimePaths = [ ./runtime ];
          extraLuaFiles = [
            # ./autocmds.lua
          ];
          globals.mapleader = " ";
          enableLuaLoader = true;

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
            inccommand = "split";
            termguicolors = true;
            timeoutlen = 1000;
            scrolloff = 4;
            sidescrolloff = 4;
            cursorline = true;
            encoding = "utf-8";
            fileencoding = "utf-8";
            fillchars = "eob: "; # Disable the "~" chars at end of buffer
          };

          ui = {
            noice = {
              enable = false;
              setupOpts = {
                lsp.progress.enabled = false;
                notify.enabled = false;
              };
            };

            borders = enabled;
            illuminate = enabled;
          };

          statusline.lualine = {
            enable = true;
          };

          dashboard.alpha = {
            enable = true;
            theme = "theta";
          };

          visuals.fidget-nvim = {
            enable = true;
            setupOpts = {
              notification.window = {
                winblend = 0;
                border = "none";
              };
            };
          };

          mini = {
            icons = enabled;
            surround = {
              enable = true;
              setupOpts = {
                mappings = {
                  add = "ys";
                  delete = "ds";
                  replace = "cs";
                  find = "yf";
                  find_left = "yF";
                  highlight = "yh";
                  update_n_lines = "yn";
                };
                n_lines = 1000;
              };
            };
            pairs = enabled;

            sessions = {
              enable = true;
              setupOpts = {
                autoread = true;
              };
            };

            git = enabled;
            diff = enabled;
            move = {
              enable = false;
              setupOpts.mappings = {
                left = "<left>";
                right = "<right>";
                down = "<down>";
                up = "<up>";
                line_left = "<left>";
                line_right = "<right>";
                line_down = "<down>";
                line_up = "<up>";
              };
            };
          };

          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
            setupOpts = {
              direction = "float";
            };
          };

          utility.snacks-nvim = {
            enable = true;
            setupOpts = {
              enimate.enabled = true;
              bigfile.enabled = true;
              # picker = {
              #   enabled = false;
              #   sources = {
              #     explorer = {
              #       layout = {
              #         preset = "vertical";
              #         preview = true;
              #       };
              #       auto_close = true;
              #     };
              #   };
              # };
              # dashboard.enabled = true;
              input.enabled = true;
              indent = {
                enabled = true;
              };
              image.enabled = true;
              rename = {
                enabled = true;
              };
              scope = {
                enabled = true;
              };
              git = {
                enabled = true;
              };
              gitbrowse = {
                enabled = true;
              };
              notify = {
                enabled = true;
              };
              notifier = {
                enabled = true;
              };
              statuscolumn.enabled = true;
              # explorer = {
              #   enabled = false;
              #   replace_netrw = true;
              # };
              words = {
                enabled = true;
              };
            };
          };
          utility.yazi-nvim = {
            enable = true;
            mappings = {
              openYazi = "<leader><space>";
            };
          };

          theme = {
            enable = true;
            name = "base16";
            transparent = true;
            base16-colors = {
              base00 = "#ffffff"; # Hintergrund
              base01 = "#f8f8f8"; # heller Hintergrund
              base02 = "#e0e0e0"; # Auswahl
              base03 = "#7a7a7a"; # Kommentar (neu, dunkler)
              base04 = "#505050"; # hellere Kommentare / Sekundärtext
              base05 = "#000000"; # Standard-Text
              base06 = "#202020"; # dunkler Text
              base07 = "#101010"; # sehr dunkler Text
              base08 = "#a60000"; # Rot (Fehler)
              base09 = "#b65c00"; # Orange
              base0A = "#a45bad"; # Magenta
              base0B = "#006800"; # Grün
              base0C = "#205ea6"; # Cyan/Blau
              base0D = "#1f1f1f"; # Dunkelblau
              base0E = "#721045"; # Violett
              base0F = "#8f0075"; # Pink
            };
          };

          binds = {
            whichKey = {
              enable = true;
              setupOpts = {
                # preset = "helix";
                win.border = "none";
              };
            };
            cheatsheet = enabled;
          };

          languages = {
            # Options applied to all languages
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;
            enableDAP = true;

            # Languages
            nix = {
              enable = true;
              lsp = {
                enable = true;
                server = ["nixd"];
              };
              treesitter.enable = true;
              extraDiagnostics.enable = true;
            };
            go.enable = true;
            php = {
              enable = true;
              lsp.server = ["intelephense"];
              lsp.enable = true;
              treesitter.enable = true;
            };
            python = {
              enable = true;
              lsp.enable = true;
              format.enable = true;
              treesitter.enable = true;
            };
            html = {
              enable = true;
              treesitter = {
                enable = true;
                autotagHtml = true;
              };
            };
            bash.enable = true;
            # yaml.enable = true;
            markdown.enable = true;
          };
          lsp = {
            enable = true;
            formatOnSave = true;
            # lspkind.enable = true;
            trouble.enable = true;
            otter-nvim.enable = true;
            lspsaga.enable = false;
            null-ls = enabled;
          };

          telescope = {
            enable = true;
            mappings = {
              buffers = "<leader>fb";
              findFiles = "<leader>ff";
            };
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
              blade
              html
            ];
          };

          keymaps = [
            # {
            #   action = "<cmd>lua Snacks.picker.projects()<CR>";
            #   desc = "Change current project.";
            #   key = "<leader>fp";
            #   mode = "n";
            # }
            # {
            #   action = "<cmd>lua Snacks.picker.smart()<CR>";
            #   desc = "Open Smart Picker.";
            #   key = "<leader><space>";
            #   mode = "n";
            # }
            #
            # {
            #   action = "<cmd>lua Snacks.picker.files()<CR>";
            #   desc = "Find Files.";
            #   key = "<leader>ff";
            #   mode = "n";
            # }
            # {
            #   action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
            #   desc = "LSP Symbols";
            #   key = "<leader>ss";
            #   mode = "n";
            # }
            #
            # {
            #   action = "<cmd>lua Snacks.explorer()<CR>";
            #   desc = "Open explorer.";
            #   key = "<leader>e";
            #   mode = "n";
            # }
            # {
            #   action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
            #   desc = "LSP Workspace Symbols";
            #   key = "<leader>sw";
            #   mode = "n";
            # }
          ];

          luaConfigPost = ''


            if vim.g.neovide then
              vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
              vim.keymap.set('v', '<D-c>', '"+y') -- Copy
              vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
              vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
              vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
              vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
            end
            vim.filetype.add({
             pattern = {
              ['.*%.blade%.php'] = 'php',
             }
            });
          '';
        };
      };
    };
  };
}
