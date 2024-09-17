{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.shell;
in
{
  options.profiles.internal.shell = with types; {
    enable = mkBoolOpt true "Enable Shell Options";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.flake
      pkgs.neovim
      pkgs.htop
      pkgs.tmux
      pkgs.rclone
      pkgs.uv
      pkgs.direnv
      pkgs.devenv
      pkgs.nixd
    ];
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

     programs.tmux = {
    enable = true;

    terminal = "screen-256color";

    prefix = "C-Space";
    shortcut = "Space";

    shell = "${pkgs.zsh}/bin/zsh";

    newSession = true;
    baseIndex = 1;
    historyLimit = 100000;
    aggressiveResize = true;
    secureSocket = true;

    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];

    extraConfig = ''
      # Enable mouse mode
      set -g mouse on
       # Use Alt-arrow keys WITHOUT PREFIX KEY to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      bind -n S-Left previous-window
      bind -n S-Right next-window
      bind -n C-T new-window

      #-------------------------------------------------------#
      # Set window name to folder name
      set-option -g status-interval 5
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'
    '';
      };

    programs.direnv.enable = true;

    programs.bottom = {
      enable = true;
    };
    programs.gh = {
      enable = true;
      settings = {
        version = 1;
        git_protocol = "https";
        editor = "micro";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
        };
      };
      extensions = [ pkgs.gh-poi ];
    };

    programs.git = {
      enable = true;
      ignores = [
        ".envrc"
        "key.properties"
        "keystore.properties"
        "*.jks"
        ".direnv/"
        "fleet.toml"
        ".DS_Store"
      ];
      lfs.enable = true;
      extraConfig = {
        branch.sort = "-committerdate";
        core = {
          autocrlf = "input";
        };
        commit.verbose = true;
        fetch = {
          fsckobjects = true;
          prune = true;
        };
        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        push.autoSetupRemote = true;
        receive.fsckObjects = true;
        transfer.fsckobjects = true;
      };
    };

    programs.bash = {
      enable = true;
      historySize = 1000;
      historyFile = "${config.home.homeDirectory}/.bash_history";
      historyFileSize = 10000;
      historyControl = [
        "erasedups"
        "ignoreboth"
      ];
      shellOptions = [
        # Append to history file rather than replacing it.
        "histappend"

        # check the window size after each command and, if
        # necessary, update the values of LINES and COLUMNS.
        "checkwinsize"

        # Extended globbing.
        "extglob"
        "globstar"

        # Warn if closing shell with running jobs.
        "checkjobs"
      ];
      bashrcExtra = ''
        # Load completions from system
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      '';
    };
  };

}
