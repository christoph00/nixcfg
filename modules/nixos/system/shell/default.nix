{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.shell;
in {
  options.chr.system.shell = with types; {
    enable = mkBoolOpt true "Whether or not to enable shell config.";
  };

  config = mkIf cfg.enable {
    environment = {
      shells = with pkgs; [zsh];

      shellAliases = {
        ll = "ls -lah";
      };

      systemPackages = with pkgs; [
        killall
        tree
        ripgrep
        wget
        git
        ncdu
        btop
        neofetch
        unzip


      ];

      localBinInPath = true;
    };

    programs.zsh.enable = true;
    programs.ssh.startAgent = true;
  };
}
