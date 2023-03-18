{...}: {
  programs.nixneovim = {
    enable = true;

    # NixNeovim contains some colorschemes
    colorschemes.gruvbox.enable = true;

    # to install plugins just activate their modules
    plugins = {
      lsp = {
        enable = true;
        hls.enable = true;
        rust-analyzer.enable = true;
      };
      treesitter = {
        enable = true;
        indent = true;
      };
      mini = {
        enable = true;
        ai.enable = true;
        jump.enable = true;
      };
    };

    # Not all plugins have own modules
    # You can add missing plugins here
    # `pkgs.vimExtraPlugins` is added by the overlay you added at the beginning
    # For a list of available plugins, look here: [available plugins](https://github.com/jooooscha/nixpkgs-vim-extra-plugins/blob/main/plugins.md)
    #extraPlugins = [ pkgs.vimExtraPlugins.<plugin> ];
  };
}
