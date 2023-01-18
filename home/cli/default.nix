{
  pkgs,
  inputs,
  system,
  config,
  ...
}:
with config.colorscheme; let
  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in {
  home.packages = with pkgs; [
    ripgrep
    htop
    pfetch
    bc # Calculator
    bottom # System viewer
    ncdu # TUI disk usage
    exa # Better ls
    ripgrep # Better grep
    fd # Better find
    jq # JSON pretty printer and manipulator
    skim

    nil
    alejandra
    cachix
    inputs.agenix.defaultPackage.x86_64-linux

    vscode-cli

    rclone
    rsync

    tmux
  ];

  home.sessionVariables = {
    PF_INFO = "ascii title os kernel uptime shell term desktop scheme palette";

    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.language = {
    base = localeGerman;
    address = localeGerman;
    collate = localeEnglish;
    ctype = localeEnglish;
    measurement = localeGerman;
    messages = localeEnglish;
    monetary = localeGerman;
    name = localeGerman;
    numeric = localeGerman;
    paper = localeGerman;
    telephone = localeGerman;
    time = localeGerman;
  };

  systemd.user.startServices = "sd-switch";

  services.syncthing.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
    };
    userName = "Christoph Asche";
    userEmail = "christoph@asche.co";
    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      url."https://github.com/".insteadOf = "git://github.com/";
    };
    lfs = {enable = true;};
    ignores = [".direnv" "result"];
    #signing = {
    #  signByDefault = true;
    #  key = "TODO";
    #};
  };

  programs = {
    bat.enable = true;
    autojump.enable = false;
    fzf.enable = true;
    jq.enable = true;
    ssh.enable = true;
    home-manager.enable = true;
    lazygit.enable = true;
    nnn.enable = true;
    gh.enable = true;
  };

  xdg.configFile."zellij/themes/${slug}.kdl".text = ''
    themes {
      ${slug} {
        fg "#${colors.base05}"
        bg "#${colors.base00}"
        black "#${colors.base03}"
        red "#${colors.base08}"
        green "#${colors.base0B}"
        yellow "#${colors.base0A}"
        blue "#${colors.base0D}"
        magenta "#${colors.base0E}"
        cyan "#${colors.base0C}"
        white "#${colors.base05}"
        orange "#${colors.base0F}"
      }
    }
  '';

  programs.zellij = {
    enable = true;
    settings = {
      default_mode = "normal";
      ui.pane_frames.rounded_corners = true;
      default_layout = "compact";
      simplified_ui = true;
      pane_frames = true;
      scrollback_editor = "hx";
      theme = "${slug}";
    };
  };

  programs.bash = {
    enable = true;
    historySize = 10000;
    shellOptions = [
      # Auto cd to directories
      "autocd"

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

    initExtra = ''
      # --- Vi mode ---
      set -o vi
      bind -m vi-insert 'Control-l: clear-screen'
      . "${pkgs.fzf}/share/fzf/completion.bash"
      . "${pkgs.fzf}/share/fzf/key-bindings.bash"
      bind -x '"\t": fzf_bash_completion'
      # --- Colored man pages ---
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'
    '';
  };

  programs.fish = {
    enable = false;
    shellAbbrs = {
      ls = "exa";
    };
    shellAliases = {
      # Get ip
      getip = "curl ifconfig.me";
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    functions = {
      fish_greeting = "";
      wh = "readlink -f (which $argv)";
    };

    plugins = [
      {
        name = "fzf-fish";
        inherit (pkgs.fishPlugins.fzf-fish) src;
      }
      {
        name = "colored-man-pages";
        inherit (pkgs.fishPlugins.colored-man-pages) src;
      }
      {
        name = "autopair";
        inherit (pkgs.fishPlugins.autopair-fish) src;
      }
      {
        name = "pure";
        inherit (pkgs.fishPlugins.pure) src;
      }
    ];
    interactiveShellInit =
      # Open command buffer in vim when alt+e is pressed
      ''
        bind \ee edit_command_buffer
      ''
      +
      # Use terminal colors
      ''
        set -U fish_color_autosuggestion      brblack
        set -U fish_color_cancel              -r
        set -U fish_color_command             brgreen
        set -U fish_color_comment             brmagenta
        set -U fish_color_cwd                 green
        set -U fish_color_cwd_root            red
        set -U fish_color_end                 brmagenta
        set -U fish_color_error               brred
        set -U fish_color_escape              brcyan
        set -U fish_color_history_current     --bold
        set -U fish_color_host                normal
        set -U fish_color_match               --background=brblue
        set -U fish_color_normal              normal
        set -U fish_color_operator            cyan
        set -U fish_color_param               brblue
        set -U fish_color_quote               yellow
        set -U fish_color_redirection         bryellow
        set -U fish_color_search_match        'bryellow' '--background=brblack'
        set -U fish_color_selection           'white' '--bold' '--background=brblack'
        set -U fish_color_status              red
        set -U fish_color_user                brgreen
        set -U fish_color_valid_path          --underline
        set -U fish_pager_color_completion    normal
        set -U fish_pager_color_description   yellow
        set -U fish_pager_color_prefix        'white' '--bold' '--underline'
        set -U fish_pager_color_progress      'brwhite' '--background=cyan'

        set -U pure_symbol_prompt        ''
        set -u pure_show_prefix_root_prompt true

      '';
  };

  home.persistence = {
    "/nix/persist/home/christoph" = {
      directories = [
        "Dokumente"
        "Downloads"
        "Bilder"
        "Videos"
        "Code"
        ".ssh"
        ".config/syncthing"
        ".config/gh"
      ];
      allowOther = true;
      files = [".local/share/fish/fish_history"];
    };
  };
}
