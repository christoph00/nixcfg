{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.emacs;
in {
  options.chr.apps.emacs = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
    defaultEditor = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.sessionVariables = mkIf cfg.defaultEditor {
          EDITOR = "emacs";
        };
        programs.emacs = {
          enable = true;
          package = pkgs.emacs-gtk3;
          extraPackages = epkgs: [epkgs.mu4e];
        };

        home.packages = with pkgs; [nixpkgs-fmt nixfmt mu];
      };
    };
  };
}
