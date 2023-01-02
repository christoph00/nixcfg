{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.conf.applications.emacs;
in {
  options.conf.applications.emacs.enable = lib.mkEnableOption "Emacs";

  config.home-manager.users.${config.conf.users.user} = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacsWithPackagesFromUsePackage {
        config = ./emacs.el;
        package = pkgs.emacsPgtk;
        alwaysEnsure = true;
        extraEmacsPackages = epkgs: with epkgs; [org-contrib];
      };
    };
    home.packages = with pkgs; [
      imagemagick
      pandoc
      ripgrep
      fd
      wl-clipboard # may come in handy
    ];
  };
}
