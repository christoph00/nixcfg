{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell;

  v3 = with pkgs.pkgsx86_64_v3-core; [
    curl
    bash
    elfutils
    diffutils
    debugedit
    file
    less
    which
  ];
in
{
  options.internal.shell = with types; {
    enable = mkBoolOpt true "Whether or not to configure shell config.";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings = {
        vim.viAlias = false;
        vim.vimAlias = true;
        vim.lsp = {
          enable = true;
        };
      };
    };

    environment.enableAllTerminfo = true;
    programs.direnv.enable = true;
    environment.systemPackages = [
      pkgs.git
      pkgs.htop
      pkgs.doas-sudo-shim
      pkgs.wget
      # pkgs.neovim
      pkgs.github-cli
      pkgs.gcc
      pkgs.ripgrep
      pkgs.unzip
      pkgs.pciutils
      pkgs.jq
      pkgs.killall
      pkgs.nh
      pkgs.devenv
      pkgs.tmux
    ];
  };
}
