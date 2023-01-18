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
    fzf

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
    jq.enable = true;
    ssh.enable = true;
    home-manager.enable = true;
    lazygit.enable = true;
    nnn.enable = true;
    gh.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
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

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableAutosuggestions = true;

    history = {
      size = 50000;
      save = 500000;
      path = "/nix/persist/home/christoph/.history";
      ignoreDups = true;
      share = true;
      extended = true;
    };

    sessionVariables = {
      LEDGER_COLOR = "true";
      LESS = "-FRSXM";
      LESSCHARSET = "utf-8";
      PAGER = "less";
      PROMPT = "%m %~ $ ";
      PROMPT_DIRTRIM = "2";
      RPROMPT = "";
      TINC_USE_NIX = "yes";
      WORDCHARS = "";
    };

    shellAliases = {
      ls = "${pkgs.coreutils}/bin/ls --color=auto";
      nm = "${pkgs.findutils}/bin/find . -name";
      scp = "${pkgs.rsync}/bin/rsync -aP --inplace";
    };
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
    };
  };
}
