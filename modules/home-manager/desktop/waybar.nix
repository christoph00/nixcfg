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
    programs.waybar.settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "DP-1"
        ];
        modules-left = ["wlr/workspaces"];
        modules-center = [
          "clock#time"
        ];
        modules-right = [
          "temperature"
          "tray"
          "wireplumber"
          "clock#date"
        ];

        "clock#time" = {format = "{:%I:%M %p}";};

        "clock#date" = {format = "{:%A, %B %d}";};

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
