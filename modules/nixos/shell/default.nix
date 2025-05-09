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
    # ./neovim
    # ./devtools.nix
  ];
  options.shell = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    programs.direnv = enabled;
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
      git
    ];

  };
}
