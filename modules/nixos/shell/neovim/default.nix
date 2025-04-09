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

      settings = {
        vim = {
          useSystemClipboard = true;
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

            borders.enable = true;
            illuminate.enable = true;
          };

          statusline.lualine.enable = true;

          mini = {
            icons.enable = true;
            # statusline.enable = true;
            # tabline.enable = true;
            # git.enable = true;
            # diff.enable = true;
            # align.enable = true;
            notify.enable = true;
            # files.enable = true;
          };

          utility.snacks-nvim = {
            enable = true;
            setupOpts = {
              bigfile.enabled = true;
              picker = {
                enabled = true;
                sources = {
                  explorer = {
                    layout = {
                      preset = "vertical";
                      preview = true;
                    };
                    auto_close = true;
                  };
                };
              };
              #dashboard.enabled = true;
              input.enabled = true;
              indent = {
                enabled = true;
              };
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

              explorer = {
                enabled = true;
                replace_netrw = true;
              };
            };
          };
          theme = {
            enable = true;
            name = "tokyonight";
            transparent = true;
            style = "day";
          };

          binds = {
            whichKey = {
              enable = true;
              setupOpts = {
                preset = "helix";
                win.border = "none";
              };
            };
            cheatsheet.enable = true;
          };
          assistant = {
            copilot.enable = true;
          };
          autocomplete.enableSharedCmpSources = true;
          autocomplete.blink-cmp = {
            enable = true;
            mappings = {
              next = "<Down>";
              previous = "<Up>";
            };
            setupOpts = {
              signature.enabled = true;

              keymap = {
                preset = "enter";
                "<C-y>" = [ "select_and_accept" ];
              };
              sources = {
                default = [
                  "lsp"
                  "path"
                  "snippets"
                  "buffer"
                  "copilot"
                ];
              };
              completion = {
                accept.auto_brackets.enabled = true;
                menu.draw.treesitter = [ "lsp" ];
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 100;
                };
              };

            };
          };

          lazy.plugins = {
            "supermaven-nvim" = {
              package = pkgs.vimPlugins.supermaven-nvim;
              setupModule = "supermaven-nvim";
              setupOpts = {
                enabled = true;
                keymaps = {
                  accept_suggestion = "<C-y>";
                  clear_suggestion = "<C-n>";
                  accept_word = "<C-w>";
                };
              };
              event = [ "InsertEnter" ];
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
            enable = true;
            lspconfig.enable = true;
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

          keymaps = [
            {
              action = "<cmd>lua Snacks.picker.projects()<CR>";
              desc = "Change current project.";
              key = "<leader>p";
              mode = "n";
            }
          ];
        };
      };
    };
  };
}
