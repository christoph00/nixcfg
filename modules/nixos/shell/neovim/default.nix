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

          # statusline.lualine.enable = true;

          mini = {
            icons.enable = true;

            # tabline.enable = true;
            # git.enable = true;
            diff.enable = true;
            # align.enable = true;
            # notify.enable = true;
            # files.enable = true;
          };

          utility.snacks-nvim = {
            enable = true;
            setupOpts = {
              enimate.enabled = true;
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
              explorer = {
                enabled = true;
                replace_netrw = true;
              };
              words = {
                enabled = true;
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
          assistant.copilot = {
            enable = true;
            cmp.enable = true;
          };
          assistant.codecompanion-nvim = {
            enable = true;
            setupOpts = {
              opts.language = "German";
              adapters =
                lib.generators.mkLuaInline
                  # lua
                  ''
                    {
                      perplexity = function ()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                          env = {
                            url = "https://api.perplexity.ai",
                            chat_url = "/v1/chat/completions",
                            api_key = "PERPLEXITY_API_KEY",
                          },  
                          schema = {
                            model = {
                              default = "sonar",
                            }
                          }
                        })
                      end
                    }
                  '';
              strategies = {
                chat.adapter = "copilot";
                inline.adapter = "copilot";
              };
              display.diff.provider = "mini_diff";
            };
          };
          autocomplete.enableSharedCmpSources = true;
          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            mappings = {
              confirm = "<Tab>";
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
                  "codecompanion"
                  "copilot"
                  # "avante_commands"
                  # "avante_mentions"
                  # "avante_files"
                ];
                # providers = {
                #   avante_commands = {
                #     name = "avante_commands";
                #     module = "blink.compat.source";
                #   };
                #   avante_mentions = {
                #     name = "avante_mentions";
                #     module = "blink.compat.source";
                #   };
                #   avante_files = {
                #     name = "avante_files";
                #     module = "blink.compat.source";
                #   };
                # };
              };
              completion = {
                ghost_text.enabled = true;
                accept = {
                  auto_brackets = {
                    enabled = false;
                    semantic_token_resolution = {
                      enabled = true;
                    };
                  };
                };
                menu.draw.treesitter = [ "lsp" ];
                menu = {
                  border = [
                    [
                      "󱐋"
                      "WarningMsg"
                    ]
                    "─"
                    "╮"
                    "│"
                    "╯"
                    "─"
                    "╰"
                    "│"
                  ];
                  winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None";
                };
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 100;
                  window.border = [
                    [
                      "󰙎"
                      "DiagnosticOk"
                    ]
                    "─"
                    "╮"
                    "│"
                    "╯"
                    "─"
                    "╰"
                    "│"
                  ];
                };
              };

            };
          };

          # extraPlugins = with pkgs.vimPlugins; {
          #   avante = {
          #     package = avante-nvim;
          #     setup = "require('avante').setup {
          #     provider = 'perplexity',
          #     auto_suggest_provider = 'copilot',
          #     vendors = {
          #       perplexity = {
          #         __inherited_from = 'openai',
          #         api_key_name = 'PERPLEXITY_API_KEY',
          #        endpoint = 'https://api.perplexity.ai',
          #        model = 'sonar',
          #       },
          #     },
          #     windows = {
          #     position = 'right',
          #       width = 50,
          #     },
          #   }";
          #   };
          # };
          #
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
            lspsaga.enable = true;
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
            ];
          };

          keymaps = [
            {
              action = "<cmd>lua Snacks.picker.projects()<CR>";
              desc = "Change current project.";
              key = "<leader>fp";
              mode = "n";
            }
            {
              action = "<cmd>lua Snacks.picker.smart()<CR>";
              desc = "Open Smart Picker.";
              key = "<leader><space>";
              mode = "n";
            }
            {
              action = "<cmd>lua Snacks.picker.files()<CR>";
              desc = "Find Files.";
              key = "<leader>ff";
              mode = "n";
            }
            {
              action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
              desc = "LSP Symbols";
              key = "<leader>ss";
              mode = "n";
            }
            {
              action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
              desc = "LSP Workspace Symbols";
              key = "<leader>sw";
              mode = "n";
            }
            {
              mode = "n";
              key = "<leader>aa";
              action = "<cmd>CodeCompanionActions<CR>";
              desc = "CodeCompanion Actions";
            }
            {
              mode = "v";
              key = "<leader>aa";
              action = "<cmd>CodeCompanionActions<CR>";
              desc = "CodeCompanion Actions";
            }
            {
              mode = "n";
              key = "<leader>ac";
              action = "<cmd>CodeCompanionChat<CR>";
              desc = "Open Code Companion Chat";
            }
            {
              mode = "n";
              key = "<leader>ap";
              action = "<cmd>CodeCompanion<CR>";
              desc = "Open Code Companion Prompt";
            }
          ];
        };
      };
    };
  };
}
