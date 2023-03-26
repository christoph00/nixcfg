{pkgs, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    xwayland = true;
    extraPackages = with pkgs; [
      waybar
      swaybg
      wofi
      imv
      kanshi
      swaylock
      swayidle
      slurp
      clipman
      wl-clipboard
      grim
      wlr-randr
      libinput
      wev
    ];
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
    };
  };
}
