{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.conf.cli;
in {
  options.conf.cli = {
    enable = mkEnableOption "Cli Config";
  };

  imports = [./helix.nix ./nvim.nix];

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };

    home-manager.users.${config.conf.users.user} = {
      programs.bat = {
        enable = true;
      };

      programs.fish = {
        enable = true;
        shellAbbrs = {
          ls = "exa";

          jqless = "jq -C | less -r";

          n = "nix";
          nd = "nix develop -c $SHELL";
          ns = "nix shell";
          nsn = "nix shell nixpkgs#";
          nb = "nix build";
          nbn = "nix build nixpkgs#";
          nf = "nix flake";

          nr = "nixos-rebuild --flake .";
          nrs = "nixos-rebuild --flake . switch";
          snr = "sudo nixos-rebuild --flake .";
          snrs = "sudo nixos-rebuild --flake . switch";
          hm = "home-manager --flake .";
          hms = "home-manager --flake . switch";
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

      home = {
        packages = with pkgs; [
          pfetch
          bc # Calculator
          bottom # System viewer
          ncdu # TUI disk usage
          exa # Better ls
          ripgrep # Better grep
          fd # Better find
          jq # JSON pretty printer and manipulator
          #xplr
          ranger

          #sops # Deployment secrets tool
          nil # Nix LSP
          nvd

          inputs.alejandra.defaultPackage."${pkgs.system}"

          agenix

          cachix
        ];
        sessionVariables = {
          PF_INFO = "ascii title os kernel uptime shell term desktop scheme palette";

          MANPAGER = "sh -c 'col -bx | bat -l man -p'";
          EDITOR = "hx";
          VISUAL = "hx";
        };
      };

      programs.ssh = {
        enable = true;
        #matchBlocks = {
        #   net = {
        #     host = builtins.concatStringsSep " " hostnames;
        #     forwardAgent = true;
        #     # remoteForwards = [{
        #     #   bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
        #     #   host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
        # }];
        #   };
        #trusted = lib.hm.dag.entryBefore ["net"] {
        #  #host = "m7.rs *.m7.rs *.ts.m7.rs";
        #  forwardAgent = true;
        #};
        #    };
      };

      home.persistence = {
        "/persist/home/christoph".directories = [".ssh"];
        "/persist/home/christoph".files = [".local/share/fish/fish_history"];
      };
    };
  };
}
