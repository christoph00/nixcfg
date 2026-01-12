_: {
  config.programs.nvf.settings.vim.languages = {
    enableFormat = true;
    enableTreesitter = true;
    enableExtraDiagnostics = true;
    enableDAP = true;

    # Languages
    nix = {
      enable = true;
      lsp = {
        enable = true;
        servers = ["nixd"];
      };
      extraDiagnostics.enable = true;
    };
    go.enable = true;
    go.lsp.enable = true;
    php = {
      enable = true;
      lsp.servers = ["intelephense"];
      lsp.enable = true;
    };
    python = {
      enable = true;
      lsp.enable = true;
      format = {
        enable = true;
        type = ["ruff"];
      };
    };
    html = {
      enable = true;
      lsp.enable = true;
      treesitter = {
        autotagHtml = true;
      };
    };
    bash.enable = true;
    yaml.enable = true;
    markdown = {
      enable = true;
      extensions.markview-nvim.enable = true;
    };
  };
}
