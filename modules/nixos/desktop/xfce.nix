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
      waylandSessionCompositor = "labwc";
      noDesktop = false;
      enableScreensaver = false;

    };

    environment.xfce.excludePackages = [ ];
    programs.xfconf.enable = true;
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-vcs-plugin
      thunar-media-tags-plugin
    ];

    home.packages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-windowck-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-timer-plugin
      xfce.xfce4-time-out-plugin
      xfce.xfce4-taskmanager
      xfce.xfce4-systemload-plugin
      xfce.xfce4-sensors-plugin
      xfce.xfce4-netload-plugin

      xfce.xfce4-cpufreq-plugin
      xfce.xfce4-cpugraph-plugin
      xfce.xfce4-clipman-plugin
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
