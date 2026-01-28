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

  options.desktop.xfce = {
    enable = mkBoolOpt config.desktop.enable;
  };

  config = mkIf config.desktop.xfce.enable {

    services.xserver.desktopManager.xfce = {

      enable = true;
      enableXfwm = false;
      enableWaylandSession = true;
      waylandSessionCompositor = "labwc --startup";
      noDesktop = false;
      enableScreensaver = false;

    };

    environment.xfce.excludePackages = [ ];
    programs.xfconf.enable = true;

    home.packages = with pkgs; [
    ];

    # programs.uwsm.waylandCompositors = {
    #   xfce = {
    #     prettyName = "Labwc";
    #     comment = "A stacking Wayland compositor.";
    #     binPath = "${pkgs.xfce}/bin/xfce";
    #   };
    # };

  };

}
