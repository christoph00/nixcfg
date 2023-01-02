{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.conf.cli.nvim;
  alejandra = inputs.alejandra.defaultPackage.${pkgs.system};
in {
  options.conf.cli.nvim.enable = lib.mkEnableOption "nvim";

  config.home-manager.users.${config.conf.users.user} = lib.mkIf cfg.enable {
    imports = [inputs.nixvim.homeManagerModules.nixvim];

    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      options = {
        # Mouse support
        mouse = "a";

        # Background
        background = "dark";

        # Enable filetype indentation
        #filetype plugin indent on

        termguicolors = true;

        # Line Numbers
        number = true;
        relativenumber = false;

        # Spellcheck
        spelllang = "en_us";

        # Use X clipboard
        clipboard = "unnamedplus";

        # Some defaults
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
      };
      plugins.lsp.enable = true;
      plugins.lsp.servers.rnix-lsp.enable = true;

      colorschemes = {
        onedark.enable = true;
        #
        #   # tokyonight = {
        #   #   enable = true;
        #   #   darkSidebar = true;
        #   #   darkFloat = true;
        #   #   lualineBold = true;
        #   #   transparent = true;
        #   #   style = "storm";
        #   # };
      };

      extraPlugins = with pkgs.vimPlugins; [
        vim-nix
      ];

      plugins.telescope.enable = true;

      maps.normal = {
        "<leader>ff" = "<cmd>Telescope find_files<cr>";
        "<leader>fg" = "<cmd>Telescope live_grep<cr>";
        "<leader>fb" = "<cmd>Telescope buffers<cr>";
        "<leader>fh" = "<cmd>Telescope help_tags<cr>";

        "<c-p>" = "<cmd>Telescope find_files<cr>";
        "<c-s-p>" = "<cmd>Telescope commands<cr>";
        "<c-k>" = "<cmd>Telescope buffers<cr>";
        "<c-s-k>" = "<cmd>Telescope keymaps<cr>";
      };
      plugins = {
        lualine = {
          enable = true;
          sections = {
            lualine_c = [
              {
                extraConfig = {
                  path = 1;
                  newfile_status = true;
                };
              }
            ];
          };
        };
        treesitter = {
          enable = true;
          indent = true;

          disabledLanguages = [
            "fish"
            "help"
            "tsx"
            "typescript"
          ];

          # This lets us temporarily create an override to update nvim-treesitter
          # See /overlays/knix.nix
          nixGrammars = false;
          ensureInstalled = [];
        };
      };
    };
  };
}
