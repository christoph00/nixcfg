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
      shells = with pkgs; [bash];

      shellAliases = {
        ll = "ls -lah";
        kssh = lib.mkIF config.chr.apps.kitty.enable "kitty +kitten ssh";
      };

      systemPackages = with pkgs; [
        killall
        tree
        ripgrep
        wget
        git
        htop
        unzip
        dig
        kitty.terminfo
      ];

      localBinInPath = true;
    };

    programs.ssh.startAgent = true;
  };
}
