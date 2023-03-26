{pkgs, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      terminal = "foot";
      gaps = {
        inner = 2;
        outer = 2;
      };
      window.border = 4;
      window.titlebar = true;
      bars = [
        {
          "command" = "${pkgs.waybar}/bin/waybar";
        }
      ];
      menu = "${pkgs.rofi}/bin/rofi -show drun -modi drun";
    };
  };
}
