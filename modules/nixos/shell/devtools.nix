{
  config,
  lib,
  pkgs,
  flake,
  perSystem,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret enabled;
  cfg = config.shell.devtools;
in {
  options.shell.devtools = {
    enable = mkBoolOpt config.host.graphical;
    tmux = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    programs.nvf = enabled;
    # programs.neovim = enabled;

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    environment.systemPackages =
      (with pkgs; [
        iwe
        fzf
        fd
        yazi
        bc
        gitu
        devenv
        curlie
        dotenvy
        go
        katana
        httrack
        nodejs
        uv
        bun
        python3
        pass
        repomix
        php
        php84Packages.composer
        python312Packages.pylance
        intelephense
        gh
        watchgha
        tree-sitter
        marksman
        fswatch
        fd
        ripgrep
        nixd
        nixfmt
        # emmylua-ls
        # stylua
      ])
      ++ (with perSystem.nix-ai-tools; [
        claude-code
        opencode
        gemini-cli
        # qwen-code
        crush
        code
      ]);

    home.rum.programs.tealdeer = {
      enable = true;
      settings = {
        auto_update = true;
      };
    };

    programs.tmux = {
      enable = cfg.tmux;
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        tokyo-night-tmux
        fzf-tmux-url
        yank
        open
      ];
      newSession = true;
      keyMode = "vi";
      extraConfig = ''
        set -g default-command "''${SHELL}" # this will avoid loading profile again
        set -g set-clipboard on
        set-option -g automatic-rename on

        set -g status-position top
        set -g mouse on

        set-option -ga terminal-overrides ",xterm*:Tc"

        bind x kill-pane
        bind q kill-window
        bind Q kill-session


        set -g @tokyo-night-tmux_theme day
        set -g @tokyo-night-tmux_transparent 1

        set -g @tokyo-night-tmux_window_id_style none
        set -g @tokyo-night-tmux_pane_id_style none
        set -g @tokyo-night-tmux_zoom_id_style none

        # Widgets
        set -g @tokyo-night-tmux_show_path 1
        set -g @tokyo-night-tmux_path_format relative

        set -g @tokyo-night-tmux_show_git 1

        set -g @tokyo-night-tmux_show_datetime 0

        set -g @tokyo-night-tmux_terminal_icon 
        set -g @tokyo-night-tmux_active_terminal_icon 

      '';
    };
  };
}
