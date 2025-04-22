{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell.devtools;
  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          aider = {
            basePackage = inputs.aider-nix.packages.${pkgs.system}.aider-chat.override {
              withAllFeatures = true;
              withPlaywright = true;
              withBrowser = true;
              withHelp = true;
            };
            flags = [
              "--env-file"
              "${config.age.secrets.aider-env.path}"
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
  options.internal.shell.devtools = with types; {
    enable = mkBoolOpt config.internal.isGraphical "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {

    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    age.secrets.aider-env = {
      file = ../../../../secrets/aider.env;
      mode = "0400";
      owner = "christoph";
    };
    environment.systemPackages = with pkgs; [
      wrapped
      iwe
      inputs.lumen.packages.${pkgs.system}.default
      fzf
      internal.project_export
      internal.open-codex
      goose-cli
      yazi
      bc

      nixfmt
      devenv
      nixd
    ];

    programs.tmux = {
      enable = true;
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
