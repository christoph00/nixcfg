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
              target = ".local/share/.codeium/bin/fa6d9e9d6113dd40a57c5478d2f4bb0e35f36b92/language_server_linux_x64";
              source = "${pkgs.codeium}/bin/codeium_language_server";
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
              incrementalSelection.enable = true;
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
                completion = {};
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
            lsp = {
              enable = true;
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

                templ = {
                  enable = true;
                  installLanguageServer = false;
                  cmd = "${pkgs.chr.templ}/bin/templ lsp";
                  filetypes = ["templ"];
                };
              };
            };
            lsp-format.enable = true;
            lsp-lines.enable = true;
            lspkind.enable = true;
            lspsaga.enable = true;
          };
          extraPlugins = with pkgs.vimPlugins; [
            vim-nix
            codeium-vim
            (pluginGit "Joe-Davidson1802" "templ.vim" "2d1ca014c360a46aade54fc9b94f065f1deb501a" "1bc3p0i3jsv7cbhrsxffnmf9j3zxzg6gz694bzb5d3jir2fysn4h")
          ];
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
