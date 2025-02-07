{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell;

  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          git = {
            basePackage = pkgs.git;
          };
          starship = {
            basePackage = pkgs.starship;
            env.STARSHIP_CONFIG.value = (pkgs.formats.toml { }).generate "starship-config" {
              character = {
                success_symbol = "[☁ ](bold purple)";
                error_symbol = "[☁ ](bold red)";
                vicmd_symbol = "[☁ ](bold green)";
              };
            };
          };
          # helix = {
          #   basePackage = pkgs.helix;
          #   flags = [
          #     "-c"
          #     (pkgs.writers.writeTOML "helix-config" {
          #       theme = "modus_vivendi";
          #       editor = {
          #         line-number = "relative";
          #         cursorline = true;
          #         true-color = true;
          #         color-modes = true;
          #         bufferline = "multiple";
          #       };
          #       editor.cursor-shape = {
          #         insert = "underline";
          #         normal = "bar";
          #       };
          #       editor.statusline = {
          #         left = [
          #           "mode"
          #           "spinner"
          #           "read-only-indicator"
          #           "file-modification-indicator"
          #         ];
          #         center = [ "file-name" ];
          #       };
          #       editor.indent-guides.render = true;
          #       editor.soft-wrap.enable = true;
          #     })
          #   ];
          # };
        };
      }
    ];
  };

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

    # environment.enableAllTerminfo = true;
    programs.direnv.enable = true;
    environment.sessionVariables = {
      COLORTERM = "truecolor";
    };
    environment.systemPackages = [
      wrapped
      pkgs.htop
      pkgs.doas-sudo-shim
      pkgs.wget
      # pkgs.neovim
      # pkgs.github-cli
      # pkgs.gcc
      pkgs.ripgrep
      pkgs.unzip
      pkgs.pciutils
      pkgs.jq
      pkgs.killall
      pkgs.devenv
      pkgs.tmux

      pkgs.agenix
      pkgs.helix
      pkgs.rsync

      pkgs.usbutils

      pkgs.nixd
      pkgs.gopls
      pkgs.go
      pkgs.just
      # pkgs.uv
      pkgs.uutils-coreutils-noprefix

    ];

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
