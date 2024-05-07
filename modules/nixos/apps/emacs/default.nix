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
    enable = mkBoolOpt' false;
    defaultEditor = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.sessionVariables = mkIf cfg.defaultEditor {EDITOR = "emacs";};
        programs.emacs = {
          enable = true;
          package = pkgs.emacs29-gtk3;
          extraPackages = epkgs: [epkgs.mu4e];
        };
      };
    };
  };
}
