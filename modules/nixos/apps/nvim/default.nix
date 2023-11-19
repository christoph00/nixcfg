{
  options,
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
    enable = mkBoolOpt' config.chr.desktop.enable;
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
              source = "${inputs.codeium-nvim.packages.${pkgs.system}.codeium-lsp}/bin/codeium_language_server";
            };
          };
        };
        programs.nixvim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          clipboard.providers.wl-copy.enable = true;
          luaLoader.enable = true;
          colorschemes.tokyonight = {
            enable = true;
            style = "night";
            transparent = true;
          };
          #          extraConfigLua = builtins.readFile ./init.lua;
          plugins = {
            which-key.enable = true;
            nvim-autopairs = {
              enable = true;
              checkTs = true;
            };
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
              };
            };
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

            nvim-cmp = {
              enable = true;
              sources = [
                {name = "buffer";}
                {name = "codeium";}
                {name = "path";}
                {name = "nvim_lsp";}
                {name = "nvim_lsp_document_symbol";}
                {name = "nvim_lsp_signature_help";}
                {name = "luasnip";}
                {name = "cmdline";}
              ];
              snippet.expand = "luasnip";
              window = {
                completion = {
                  # winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
                  scrollbar = false;
                  sidePadding = 0;
                  border = [
                    "╭"
                    "─"
                    "╮"
                    "│"
                    "╯"
                    "─"
                    "╰"
                    "│"
                  ];
                };

                documentation = {
                  border = [
                    "╭"
                    "─"
                    "╮"
                    "│"
                    "╯"
                    "─"
                    "╰"
                    "│"
                  ];
                  # winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
                };
              };
              formatting = {
                fields = ["abbr" "kind" "menu"];
                format =
                  # lua
                  ''
                    function(_, item)
                      local icons = {
                        Namespace = "󰌗",
                        Text = "󰉿",
                        Method = "󰆧",
                        Function = "󰆧",
                        Constructor = "",
                        Field = "󰜢",
                        Variable = "󰀫",
                        Class = "󰠱",
                        Interface = "",
                        Module = "",
                        Property = "󰜢",
                        Unit = "󰑭",
                        Value = "󰎠",
                        Enum = "",
                        Keyword = "󰌋",
                        Snippet = "",
                        Color = "󰏘",
                        File = "󰈚",
                        Reference = "󰈇",
                        Folder = "󰉋",
                        EnumMember = "",
                        Constant = "󰏿",
                        Struct = "󰙅",
                        Event = "",
                        Operator = "󰆕",
                        TypeParameter = "󰊄",
                        Table = "",
                        Object = "󰅩",
                        Tag = "",
                        Array = "[]",
                        Boolean = "",
                        Number = "",
                        Null = "󰟢",
                        String = "󰉿",
                        Calendar = "",
                        Watch = "󰥔",
                        Package = "",
                        Copilot = "",
                        Codeium = "",
                        TabNine = "",
                      }

                      local icon = icons[item.kind] or ""
                      item.kind = string.format("%s %s", icon, item.kind or "")
                      return item
                    end
                  '';
              };
              mapping = {
                "<C-b>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<C-e>" = "cmp.mapping.abort()";
                "<CR>" = "cmp.mapping.confirm({ select = false })";

                "<Tab>" = {
                  modes = ["i" "s"];

                  action = ''
                    function(fallback)
                      unpack = unpack or table.unpack
                      local line, col = unpack(vim.api.nvim_win_get_cursor(0))

                      if cmp.visible() then
                        cmp.select_next_item()
                      else
                        local _, err = pcall(function()
                          if vim.fn["vsnip#available"](1) == 1 then
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "", true)
                          else
                            error({code=121})
                          end
                        end)

                        if err.code == 121 and col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil then
                          cmp.complete()
                        else
                          fallback()
                        end
                      end
                    end
                  '';
                };

                "<S-Tab>" = {
                  modes = ["i" "s"];

                  action = ''
                    function()
                      if cmp.visible() then
                        cmp.select_next_item()
                      elseif vim.call('vsnip#jumpable', -1) == 1 then
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-jump-prev)", true, true, true), "", true)
                      end
                    end
                  '';
                };
              };

              mappingPresets = ["cmdline" "insert"];
            };
            harpoon = {
              enable = true;
              enableTelescope = true;
            };
            lsp = {
              enable = true;
              enabledServers = ["templ"];
              servers = {
                denols.enable = true;
                gopls.enable = true;
                html.enable = true;
                lua-ls.enable = true;
                nixd = {
                  enable = true;
                  settings = {
                    formatting.command = "${pkgs.alejandra}/bin/alejandra";
                  };
                };
                tailwindcss.enable = true;
              };
            };

            lsp-format.enable = true;
            lsp-lines.enable = true;
            # lspkind.enable = true;
            lspsaga.enable = true;
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
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')

            cmp.event:on(
              'confirm_done',
              cmp_autopairs.on_confirm_done()
            )

              -- Use buffer source for `/`
            cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })
          '';

          extraPackages = [pkgs.chr.templ];
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

          # maps = {
          #   normal = {
          #     "gh" = "<cmd>Lspsaga lsp_finder<CR>";
          #     "gr" = "<cmd>Lspsaga rename<CR>";
          #     "gd" = "<cmd>Lspsaga peek_definition<CR>";
          #   };
          #   normalVisualOp."<leader>ca" = "<cmd>Lspsaga code_action<CR>";
          #   normalVisualOp."<A-d>" = "<cmd>Lspsaga term_toggle<CR>";
          #   terminal."<A-d>" = "<cmd>Lspsaga term_toggle<CR>";
          # };
          keymaps = [
            {
              action = "<cmd>Lspsaga lsp_finder<CR>";
              key = "gh";
            }
            {
              action = "<cmd>Lspsaga code_action<CR>";
              key = "<leader>ca";
              mode = ["i" "o" "v"];
            }
          ];
        };
      };
    };
  };
}
