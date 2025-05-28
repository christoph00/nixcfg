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
      fzf
      lsd
      atuin
      starship
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


        # aliases
        alias ls=lsd

        export PATH="$HOME/.local/bin:$PATH"


        eval "$(${pkgs.starship}/bin/starship init zsh)"
        eval "$(${pkgs.atuin}/bin/atuin init zsh)"
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
          '';
        };
      };

    };

  };
}
