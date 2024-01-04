{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.cli;
  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in {
  options.chr.apps.cli = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
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

        unrar

        nixd
        gcc
        alejandra
        cachix

        chr.aichat
        chr.tgpt

        #inputs.deploy-rs.packages.${pkgs.system}.deploy-rs

        inputs.agenix.packages.${system}.default

        #vscode-cli

        rclone
        rsync

        nodejs
        python3

        tmux
        # xplr

        gopls

        #tailwindcss

        tree

        #unzip
        p7zip
        #cabextract
        #innoextract

        # wineWowPackages.staging
        # winetricks

        tio
        #picocom

        simple-http-server

        #vomit-sync
        #    vmt

        # jellyfin-ffmpeg

        #conda

        # wrangler
        flyctl
        # deno

        home-assistant-cli

        # media-sort
        #phockup
        #ffmpeg-full
        inputs.devenv.packages.${system}.devenv
      ];

      home.sessionVariables = {
        PF_INFO = "ascii title os kernel uptime shell term desktop scheme palette";
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

      programs.direnv.enable = true;

      programs.git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;
        aliases = {
          pushall = "!git remote | xargs -L1 git push --all";
          graph = "log --decorate --oneline --graph";
          nc = ''commit -a --allow-empty-message -m ""'';
        };
        userName = "Christoph Asche";
        userEmail = "christoph@asche.co";
        extraConfig = {
          feature.manyFiles = true;
          init.defaultBranch = "main";
          url."https://github.com/".insteadOf = "git://github.com/";
          merge.conflictstyle = "diff3";
          pull.rebase = true;
          rebase.autosquash = true;
          rebase.autostash = true;
          color.ui = true;
        };
        lfs = {enable = true;};
        ignores = [".direnv" "result"];
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
        bash.enable = true;
      };

      # services.rclone = {
      #   enable = true;
      #   config = "/run/agenix/rclone-conf";
      #   mounts = {
      #     nas = {
      #       from = "NDCRYPT:";
      #       to = "/home/christoph/NAS";
      #     };
      #   };
      # };

      programs.command-not-found.enable = false;
    };
  };
}
