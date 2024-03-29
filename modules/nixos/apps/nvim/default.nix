{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.nvim;
  pluginGit = owner: repo: ref: sha:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${repo}";
      version = ref;
      src = pkgs.fetchFromGitHub {
        owner = owner;
        repo = repo;
        rev = ref;
        sha256 = sha;
      };
    };
in {
  options.chr.apps.nvim = with types; {
    enable = mkBoolOpt' false;

    defaultEditor = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.packages = [pkgs.tree-sitter pkgs.ripgrep pkgs.lazygit pkgs.gdu pkgs.bottom];
        home.sessionVariables = mkIf cfg.defaultEditor {
          EDITOR = "nvim";
        };
        home = {
          file = {
            codeium = {
              target = ".local/share/.codeium/bin/39080e89780bea461f7a46e6dc1026d80a3a353a/language_server_linux_x64";
              # source = "${pkgs.codeium}/bin/codeium";
              source = "${inputs.codeium-nvim.packages.${pkgs.system}.codeium-lsp}/bin/codeium_language_server";
            };
          };
        };
        programs.nixvim = let
          border = ["╭" "─" "╮" "│" "╯" "─" "╰" "│"];
        in {
          enable = false;
          viAlias = true;
          vimAlias = true;
          clipboard.register = "unnamedplus";
          clipboard.providers.wl-copy.enable = true;
          luaLoader.enable = true;
          colorschemes.tokyonight = {
            enable = true;
            style = "night";
            transparent = true;
          };
          #          extraConfigLua = builtins.readFile ./init.lua;
          plugins = {
            # which-key = {
            #   enable = true;
            #   window = {
            #     inherit border;
            #   };
            # };
            # # nvim-autopairs = {
            #   enable = true;
            #   checkTs = true;
            # };
            telescope = {
              enable = true;
              extensions.fzf-native.enable = true;
              extraOptions.defaults.layout_config.vertical.height = 0.5;
              keymaps = {
                "<C-p>" = "find_files";
                "<leader>ff" = "find_files";
                "<leader>fg" = "live_grep";
                "<leader>fb" = "buffers";
                "<leader>fh" = "help_tags";
                "<leader>f:" = "commands";
                "<leader>fq" = "quickfix";
                "<leader>fr" = "oldfiles";
                "<leader>fd" = "diagnostics";
              };
              keymapsSilent = true;
            };
            treesitter = {
              enable = true;
              nixGrammars = true;
              folding = true;
              indent = true;
              nixvimInjections = true;
              incrementalSelection = {
                enable = true;
                keymaps = {
                  initSelection = "<C-space>";
                  nodeIncremental = "<C-space>";
                  nodeDecremental = "<bs>";
                };
              };
            };
            treesitter-context = {
              enable = true;
              maxLines = 2;
              minWindowHeight = 100;
            };
            treesitter-refactor = {
              enable = true;
              highlightCurrentScope.enable = false;
              highlightDefinitions.enable = true;
              smartRename.enable = true;
            };
            mini = {
              enable = true;
              modules = {
                basics = {
                  extra_ui = true;
                };
                ai = {
                  n_lines = 50;
                  search_method = "cover_or_next";
                };
                # completion = {};
                # indentscope = {};
                pairs = {};
                statusline = {};
                starter = {};
                surround = {};
                comment = {};
                files = {};
                tabline = {};
                clue = {};
                cursorword = {};
                extra = {};
              };
            };
            # typst-vim.enable = true;
            cmp-buffer.enable = true;

            cmp-emoji.enable = true;
            cmp-latex-symbols.enable = true;
            cmp-path.enable = true;
            cmp-cmdline.enable = true;
            cmp-treesitter.enable = true;

            cmp-nvim-lsp.enable = true;
            cmp-nvim-lsp-document-symbol.enable = true;
            cmp-nvim-lsp-signature-help.enable = true;

            luasnip.enable = true;
            cmp_luasnip.enable = true;

            cmp-look.enable = true;

            cmp = {
              enable = true;
              snippet.expand = "luasnip";
              mapping = {
                "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-e>" = "cmp.mapping.close()";
                # "<Tab>" = {
                #   modes = ["i" "s"];
                #   action = "cmp.mapping.select_next_item()";
                # };
                # "<S-Tab>" = {
                #   modes = ["i" "s"];
                #   action = "cmp.mapping.select_prev_item()";
                # };
                "<Down>" = {
                  modes = ["i" "s"];
                  action = "cmp.mapping.select_next_item()";
                };
                "<Up>" = {
                  modes = ["i" "s"];
                  action = "cmp.mapping.select_prev_item()";
                };
                "<C-j>" = {
                  modes = ["i" "s"];
                  action = "cmp.mapping.select_next_item()";
                };
                "<C-k>" = {
                  modes = ["i" "s"];
                  action = "cmp.mapping.select_prev_item()";
                };
                # "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<Tab>" = "cmp.mapping.confirm({ select = true })";
              };
              sources = [
                {name = "nvim_lsp";}
                {name = "codeium";}
                {name = "luasnip";}
                {
                  name = "look";
                  keywordLength = 2;
                  option = {
                    convert_case = true;
                    loud = true;
                  };
                }
                {name = "path";}
                {name = "buffer";}
                {name = "nvim_lua";}
                {name = "orgmode";}
              ];
            };
            harpoon = {
              enable = false;
              # enableTelescope = true;
            };
            lsp = {
              enable = true;
              enabledServers = ["templ"];
              servers = {
                denols.enable = true;
                gopls.enable = true;
                html.enable = true;
                lua-ls.enable = true;
                nil_ls = {
                  enable = true;
                  settings = {
                    # formatting.command = "${pkgs.alejandra}/bin/alejandra";
                  };
                };
                tailwindcss.enable = true;
                cssls.enable = true;
                typst-lsp.enable = true;
              };
            };

            lsp-format.enable = true;
            lsp-lines.enable = true;
            # lspkind.enable = true;
            lspsaga = {
              enable = true;
              ui = {
                inherit border;
              };
            };
            trouble.enable = true;
          };
          extraPlugins = with pkgs.vimPlugins; [
            vim-nix
            friendly-snippets

            (pluginGit "Joe-Davidson1802" "templ.vim" "2d1ca014c360a46aade54fc9b94f065f1deb501a" "1bc3p0i3jsv7cbhrsxffnmf9j3zxzg6gz694bzb5d3jir2fysn4h")
            inputs.codeium-nvim.packages.${pkgs.system}.vimPlugins.codeium-nvim
          ];

          extraConfigLua = ''
            -- Codeium
            require("codeium").setup()

            local cmp = require("cmp")
            -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')

              -- Use buffer source for `/`
            cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })
          '';

          extraPackages = [pkgs.templ];
          options = {
            number = true;
            relativenumber = true;
            shiftwidth = 0;
            tabstop = 2;
            showtabline = 2;
            expandtab = true;
            smarttab = true;
            showmode = false;
            undofile = true;
            list = true;
            completeopt = "menuone,menuone,noselect";
            foldenable = false;
            guifont = "IntoneMono Nerd Font Mono:h12";
          };

          globals = {
            mapleader = " ";
            rust_recommended_style = false;
          };

          keymaps = [
            {
              options.desc = "LSP finder";
              key = "<leader>lf";
              action = ":Lspsaga finder<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP code action";
              key = "<leader>la";
              action = ":Lspsaga code_action<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP rename";
              key = "<leader>lr";
              action = ":Lspsaga rename<CR>";
              options.silent = true;
            }
            {
              options.desc = "LSP peek definition";
              key = "<leader>ld";
              action = ":Lspsaga peek_definition<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP goto definition";
              key = "<leader>lD";
              action = ":Lspsaga goto_definition<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP peek type definition";
              key = "<leader>lt";
              action = ":Lspsaga peek_type_definition<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP goto type definition";
              key = "<leader>lT";
              action = ":Lspsaga goto_type_definition<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP format code";
              key = "<leader>lf";
              action = ":lua vim.lsp.buf.format()<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP next diagnostic";
              key = "<leader>ln";
              action = ":Lspsaga diagnostic_jump_next<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP previous diagnostic";
              key = "<leader>lN";
              action = ":Lspsaga diagnostic_jump_prev<cr>";
              options.silent = true;
            }
            {
              options.desc = "LSP hover documentation";
              key = "<leader>lh";
              action = ":Lspsaga hover_doc<cr>";
              options.silent = true;
            }
          ];
        };
      };
    };
  };
}
