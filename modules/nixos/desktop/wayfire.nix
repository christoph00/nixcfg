{
  lib,
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
in
{

  options.desktop.wayfire = {
    enable = mkBoolOpt config.desktop.enable;
  };

  config = mkIf config.desktop.wayfire.enable {

    programs.wayfire.enable = true;
    programs.wayfire.plugins = with pkgs.wayfirePlugins; [ wcm wf-shell wayfire-plugins-extra ];
    xdg.portal.config.wayfire = {
      default = "gtk;wlr";
    };

    home.packages = with pkgs; [
      brightnessctl
      fuzzel
      foot
    ];

    programs.uwsm.waylandCompositors = {
      wayfire = {
        prettyName = "wayfire";
	        comment = "Wayfire compositor managed by UWSM";
	        binPath = "/run/current-system/sw/bin/wayfire";
      };
    };

  };

}
