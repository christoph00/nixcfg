{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret;
  cfg = config.shell.devtools;
  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          aider = {
            basePackage = pkgs.aider-chat;
            flags = [
              "--env-file"
              "${config.age.secrets.aider.path}"
              "--chat-language"
              "German"
              "--vim"
              "--editor"
              "vim"
              "--cache-prompts"
              "--no-attribute-author"
              "--attribute-committer"
              "--no-check-update"
            ];
          };
        };
      }
    ];
  };
in
{
  options.shell.devtools = {
    enable = mkBoolOpt false;
    tmux = mkBoolOpt true;
  };

  config = mkIf cfg.enable {

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    age.secrets.aider = mkSecret {
      file = "aider";
      mode = "0400";
      owner = "christoph";
    };

    environment.systemPackages = with pkgs; [
      wrapped
      iwe
      fzf
      yazi
      bc
      gitu

      devenv

      curlie
    ];

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
