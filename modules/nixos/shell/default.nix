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
    ./devtools.nix
    ./office.nix
  ];
  options.shell = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    environment.enableAllTerminfo = true;
    programs.direnv = enabled;
    programs.git = enabled;
    environment.systemPackages = with pkgs; [
      htop
      wget
      vim
      ripgrep
      unzip
      pciutils
      jq
      jc
      killall
      rsync
      usbutils
      uutils-coreutils-noprefix
      dnsutils
      fzf
      lsd
    ];
    environment.shells = with pkgs; [
      # nushell
      # dash
    ];

    programs.bash = {
      enable = true;
      completion.enable = true;
      promptInit = ''
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      '';
      shellAliases = {
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -a";
        lal = "lsd -al";
      };
    };
  };
}
