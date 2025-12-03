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

  options.desktop.labwc = {
    enable = mkBoolOpt config.desktop.enable;
  };

  config = mkIf config.desktop.labwc.enable {

    programs.labwc.enable = true;

    xdg.portal.config.labwc = {
      default = "gtk;wlr";
    };

    home.packages = with pkgs; [
      labwc
      brightnessctl
      fuzzel
      foot
    ];

    programs.uwsm.waylandCompositors = {
      labwc = {
        prettyName = "Labwc";
        comment = "A stacking Wayland compositor.";
        binPath = "${pkgs.labwc}/bin/labwc";
      };
    };

  };

}
