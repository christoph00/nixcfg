{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  compileSCSS = name: source: "${
    pkgs.runCommandLocal name {} ''
      mkdir -p $out
      ${lib.getExe pkgs.sassc} -t expanded '${source}' > $out/${name}.css
    ''
  }/${name}.css";
in {
  config = lib.mkIf (osConfig.nos.desktop.bar == "waybar") {
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;
    programs.waybar.systemd.target = ["hyprland-session.target"];
    programs.waybar.settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "DP-1"
        ];
        modules-left = ["hyprland/workspaces"];
        modules-center = [
          "clock#time"
        ];
        modules-right = [
          "temperature"
          "tray"
          "wireplumber"
          "clock#date"
        ];

        "clock#time" = {format = "{:%H:%M}";};

        "clock#date" = {format = "{:%A, %d. %B}";};

        tray = {
          show-passive-items = true;
          icon-size = 12;
          spacing = 16;
        };

        wireplumber = {
          format = "{volume}% {icon}";
          format-muted = "";
          on-click = "${pkgs.helvum}/bin/helvum";
          format-icons = ["" "" ""];
        };
      };
    };
  };
}
