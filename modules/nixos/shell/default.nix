{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.shell;

in
{
  imports = [
    ./neovim
    ./devtools.nix
  ];
  options.shell = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    programs.direnv = enabled;
    programs.git = enabled;
    environment.systemPackages = with pkgs; [
      htop
      wget
      ripgrep
      unzip
      pciutils
      jq
      killall
      rsync
      usbutils
      uutils-coreutils-noprefix
      dnsutils
      bat
      batman
      fzf
    ];

    programs.zsh.enable = true;

    user.hjem.rum.programs.zsh = {
      enable = true;
      initConfig = ''
        # enable vi mode
        bindkey -v
        export KEYTIMEOUT=1

        # history
        SAVEHIST=2000
        HISTSIZE=5000

        alias man='batman'
        alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

        # aliases
        alias ls=lsd
      '';

      plugins = {
        nix-zsh-completions = {
          source = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
          completions = [ "${pkgs.nix-zsh-completions}/share/zsh/site-functions" ];
        };
        zsh-completions.completions = [ "${pkgs.zsh-completions}/share/zsh/site-functions" ];
        zsh-fzf-tab = {
          source = "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh";
          config = ''
            source <(fzf --zsh)

            # use lsd for fzf preview
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd'
            zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd'
          '';
        };
        zsh-autosuggestions = {
          source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          config = ''
            ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=gray,underline"
          '';
        };
        zsh-syntax-highlighting = {
          source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
          config = ''
            zstyle ':completion:*:*:*:*:*' menu select
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
            zstyle ':completion:*' auto-description 'specify: %d'
            zstyle ':completion:*' completer _expand _complete
            zstyle ':completion:*' format 'Completing %d'
            zstyle ':completion:*' group-name ' '
            zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
            zstyle ':completion:*' rehash true
            zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
            zstyle ':completion:*' use-compctl false
            zstyle ':completion:*' verbose true
            zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
            typeset -gA ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
            ZSH_HIGHLIGHT_STYLES[default]=none
            ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=gray,underline
            ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
            ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
            ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[path]=bold
            ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
            ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
            ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[command-substitution]=none
            ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[process-substitution]=none
            ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
            ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
            ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
            ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[assign]=none
            ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
            ZSH_HIGHLIGHT_STYLES[named-fd]=none
            ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
            ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
            ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
            ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
            ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
            ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
            ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
            ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
          '';
        };
      };

    };

  };
}
