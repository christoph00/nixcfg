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
        programs.nixvim = {
          enable = true;
          colorschemes.tokyonight = { 
            enable = true;
            style = "night";
          };
          #          extraConfigLua = builtins.readFile ./init.lua;
          plugins = {
        #    coq-nvim = {
        #      enable = true;
        #      autoStart = "shut-up";
        #      installArtifacts = true;
        #      recommendedKeymaps = true;
        #    };
            telescope = {
              enable = true;
              extensions.fzf-native.enable = true;
              extraOptions.defaults.layout_config.vertical.height = 0.5;
            };
            treesitter = {
              enable = true;
              nixGrammars = true;
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
              };
            };
          };
          extraPlugins = with pkgs.vimPlugins; [
            vim-nix
            #codeium-vim
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
