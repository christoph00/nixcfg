{
  pkgs,
  inputs,
  system,
  config,
  lib,
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
    ripgrep # Better grep
    fd # Better find
    jq # JSON pretty printer and manipulator
    fzf
    wget

    nil
    alejandra
    cachix
    inputs.agenix.defaultPackage.x86_64-linux

    vscode-cli

    rclone
    rsync

    tmux
    xplr

    comma

    gopls

    tree

    matcha

    flyctl

    unrar
    unzip
    p7zip
    cabextract
    innoextract

    wineWowPackages.staging

    # winetricks (all versions)
    winetricks
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
    collate = localeGerman;
    ctype = localeEnglish;
    measurement = localeGerman;
    messages = localeGerman;
    monetary = localeGerman;
    name = localeGerman;
    numeric = localeGerman;
    paper = localeGerman;
    telephone = localeGerman;
    time = localeGerman;
  };

  systemd.user.startServices = "sd-switch";

  #services.syncthing.enable = true;

  # programs.aria2 = {
  #   enable = true;
  #   settings = {

  #   };
  # };

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
    lf.enable = true;
    go.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    changeDirWidgetCommand = "fd --type d";
  };

  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = true;

  programs.bash = {
    enable = true;
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
        ".config/rclone"
        ".cache/nix-index"
        ".cache/rclone"
        ".config/brew" # matcha
      ];
      allowOther = true;
    };
  };
}
