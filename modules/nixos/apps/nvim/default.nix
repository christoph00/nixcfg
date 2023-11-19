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
    pkgs.vimUtils.buildVimPluginFrom2Nix {
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
              enable = false;
              highlightCurrentScope.enable = true;
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
              ];
              snippet.expand = "luasnip";

              window = {
                completion = {
                  winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
                  colOffset = -3;
                  sidePadding = 0;
                };
              };

              formatting = {
                fields = ["kind" "abbr" "menu"];
              };

              mapping = {
                "<C-k>" = "cmp.mapping.select_prev_item()";
                "<C-j>" = "cmp.mapping.select_next_item()";
                "<C-e>" = "cmp.mapping.abort()";
                "<C-b>" = "cmp.mapping.scroll_docs(-2)";
                "<C-f>" = "cmp.mapping.scroll_docs(2)";
              };
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
            lspkind.enable = true;
            lspsaga.enable = true;
          };
          extraPlugins = with pkgs.vimPlugins; [
            vim-nix
            friendly-snippets

            (pluginGit "Joe-Davidson1802" "templ.vim" "2d1ca014c360a46aade54fc9b94f065f1deb501a" "1bc3p0i3jsv7cbhrsxffnmf9j3zxzg6gz694bzb5d3jir2fysn4h")
            inputs.codeium-nvim.packages.${pkgs.system}.vimPlugins.codeium-nvim
          ];

          extraConfigLua = ''
            require("codeium").setup()
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
        };
      };
    };
  };
}
