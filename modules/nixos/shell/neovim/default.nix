{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
in
{
  imports = [
    inputs.nvf.nixosModules.default
    ./mcphub.nix
  ];

  config = mkIf config.programs.nvf.enable {

    programs.nvf = {

      settings = {
        vim = {
          additionalRuntimePaths = [ ./runtime ];
          extraLuaFiles = [
            ./autocmds.lua
            ./codecompanion-fidget.lua
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

          ashboard.alpha = {
            enable = true;
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
            cheatsheet = enabled;
          };
          assistant.copilot = {
            enable = false;
            cmp.enable = false; # Use blink-cmp
            setupOpts = {
              suggestion = {
                enabled = true;
                auto_trigger = true;
                debounce = 75;
                keymap = {
                  accept = false;
                  accept_word = false;
                  accept_line = false;
                  next = false;
                  prev = false;
                  dismiss = false;
                };
              };

              panel = {
                enabled = true;
                auto_refresh = false;
                keymap = {
                  jump_prev = false;
                  jump_next = false;
                  accept = false;
                  refresh = false;
                  open = false;
                };
              };
            };
            mappings = {
              suggestion = {
                accept = "<A-y>";
                next = "<A-n>";
                prev = "<A-p>";

                dismiss = "<A-d>";
                acceptWord = "<A-w>";
                acceptLine = "<A-l>";
              };
              panel = {
                open = "<A-CR>";
                accept = "<CR>";
                jumpNext = "]]";
                jumpPrev = "[[";
                refresh = "gr";
              };
            };
          };
          assistant.codecompanion-nvim = {
            enable = true;
            setupOpts = {
              opts.language = "German";
              adapters = {
                _type = "lua-inline";

                # Model list https://codecompanion.olimorris.dev/usage/chat-buffer/agents#compatibility
                expr = ''
                  {
                    copilot = function()
                      return require('codecompanion.adapters').extend('copilot', {
                        schema = {
                          model = {
                            default = 'claude-sonnet-4',
                            choices = {
                              'claude-sonnet-4',
                              'gpt-4.1,'
                            },
                          },
                        },
                      })
                    end,

                    openrouter = function()
                       return require("codecompanion.adapters").extend("openai_compatible", {
                         env = {
                           url = "https://openrouter.ai/api",
                           api_key = "OPENROUTER_API_KEY",
                           chat_url = "/v1/chat/completions",
                        },
                        parameters = {
                          provider = {
                            allow_fallbacks = false,
                          },
                          stream = true,
                        },
                        schema = {
                          model = {
                            default = "mistralai/devstral-small:free",
                            choices = {
                              "mistralai/devstral-small:free",
                              "meta-llama/llama-4-maverick:free",
                              -- "anthropic/claude-3.7-sonnet",
                              -- "anthropic/claude-3.5-sonnet",
                              -- "deepseek/deepseek-chat-v3-0324",
                              -- "deepseek/deepseek-r1",
                            },
                          },
                        },
                      })
                    end,

                  }
                '';
              };
              display.diff.provider = "mini_diff";
              display = {
                chat = {
                  # Basic UI improvements
                  intro_message = "Welcome to CodeCompanion ✨! Press ? for options";
                  show_header_separator = true; # Show separators between messages
                  auto_scroll = true; # Auto-scroll as responses come in

                  # Show LLM model and settings at the top
                  show_settings = false; # This displays the model being used
                  show_token_count = false; # Show token usage
                  show_references = true; # Show references from slash commands

                  # Custom token count display function
                  token_count = {
                    _type = "lua-inline";
                    expr = ''
                      function(tokens, adapter)
                        return string.format(" 🤖 %s (%d tokens)", adapter.formatted_name, tokens)
                      end
                    '';
                  };

                  # Window styling
                  separator = "─"; # Visual separator between messages
                  window = {
                    layout = "vertical";
                    border = "rounded"; # Better looking border
                    height = 0.8;
                    width = 0.45;
                  };
                };
              };

              strategies = {
                agent.adapter = "openrouter";
                chat = {
                  adapter = "openrouter";
                  roles = {
                    _type = "lua-inline";
                    expr = ''
                      {
                        llm = function(adapter)
                          return string.format("🤖 %s (%s)", adapter.formatted_name, adapter.schema.model.default)
                        end,
                        user = "👤 Me"
                      }
                    '';
                  };
                  keymaps = {
                    close = {
                      modes = {
                        n = "q";
                      };
                      index = 3;
                      callback = "keymaps.close";
                      description = "Close Chat";
                    };
                    stop = {
                      modes = {
                        n = "<C-c>";
                      };
                      index = 4;
                      callback = "keymaps.stop";
                      description = "Stop Request";
                    };
                  };
                };
                inline = {
                  adapter = "openrouter";
                };

              };

              extensions = {
                mcphub = {
                  callback = "mcphub.extensions.codecompanion";
                  opts = {
                    show_result_in_chat = true;
                    make_vars = true;
                    make_slash_commands = true;
                    auto_register_servers = true;
                  };
                };
              };

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
            sourcePlugins = {
              ripgrep = enabled;
            };
            setupOpts = {
              signature.enabled = true;

              keymap = {
                preset = "enter";
                "<C-y>" = [ "select_and_accept" ];
                "<A-y>" = [
                  (lib.generators.mkLuaInline ''
                    function(cmp)
                      cmp.show { providers = { 'minuet' } }
                    end
                  '')
                ];
              };
              sources = {
                default = [
                  "minuet"
                  "lsp"
                  "path"
                  "snippets"
                  "buffer"
                ];
                per_filetype = {
                  codecompanion = [
                    "codecompanion"
                    "buffer"
                  ];
                };
                providers = {
                  minuet = {
                    name = "minuet";
                    module = "minuet.blink";
                    async = true;
                    timeout_ms = 3000;
                    score_offset = 50;
                  };
                };
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
                  winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None";
                };
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 100;
                };
              };

            };
          };

          extraPlugins = {
            minuet = {
              package = pkgs.vimPlugins.minuet-ai-nvim;
              setup = "
            require('minuet').setup {
              provider = 'codestral',
              n_completions = 1, -- recommend for local model for resource saving
              -- I recommend beginning with a small context window size and incrementally
              -- expanding it, depending on your local computing power. A context window
              -- of 512, serves as an good starting point to estimate your computing
              -- power. Once you have a reliable estimate of your local computing power,
              -- you should adjust the context window to a larger value.
              context_window = 1024,
              provider_options = {
                codestral = {
                    model = 'codestral-latest',
                    end_point = 'https://codestral.mistral.ai/v1/fim/completions',
                    api_key = 'CODESTRAL_API_KEY',
                    stream = true,
                    optional = {
                        stop = nil, -- the identifier to stop the completion generation
                        max_tokens = nil,
                    },
                },
            },
          }
          ";
            };

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
            php = {
              enable = true;
              lsp.server = "intelephense";
              lsp.enable = true;
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
            lspconfig.enable = true;
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
