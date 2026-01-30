{
  lib,
  flake,
  config,
  pkgs,
  inputs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
in
{

  options.desktop.mangowc = {
    enable = mkBoolOpt config.desktop.enable;
  };

  config = mkIf config.desktop.mangowc.enable {


    xdg.portal.config.mangowc = {
      default = "gtk;wlr";
    };

    home.packages = with perSystem.nixpkgs-unstable; [
      mangowc
    ];

    programs.uwsm.waylandCompositors = {
      mangowc = {
        prettyName = "Mangowc";
        comment = "wayland compositor base wlroots and scenefx(dwm but wayland).";
        binPath = "${pkgs.mangowc}/bin/mango";
      };
    };

  };

}
