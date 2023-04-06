{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  btm = "${pkgs.bottom}/bin/btm";
  terminal = "${pkgs.foot}/bin/foot";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";
  launcher = "${config.programs.rofi.package}/bin/rofi -show drun";

  systemMonitor = terminal-spawn btm;

  styleCSS = with config.colorscheme.colors;
    pkgs.writeText "style.css" ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: Material Design Icons, ${config.fontProfiles.monospace.family};
        font-size: 14px;
      }

      window#waybar {
        background-color: transparent;
       }



    '';
in {
  programs.waybar = {
    enable = true;
    style = styleCSS;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      patchPhase = ''
        substituteInPlace src/modules/wlr/workspace_manager.cpp --replace "zext_workspace_handle_v1_activate(workspace_handle_);" "const std::string command = \"${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch workspace \" + name_; system(command.c_str());"
      '';
    });
    systemd.enable = false;
    settings = {
      primary = {
        layer = "top";
        height = 32;
        margin = "2";
        position = "bottom";
        spacing = 5;

        #output = builtins.map (m: m.name) (builtins.filter (m: m.isSecondary == false) config.monitors);
        modules-left = [
          "custom/menu"
          "wlr/workspaces"
          # "wlr/taskbar"
        ];
        modules-center = [
          # "hyprland/window"
        ];
        modules-right = [
          "backlight"
          "temperature"
          "cpu"
          "memory"
          "battery"
          "tray"
          "clock"
        ];

        "wlr/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };
        clock = {
          format = "{:%H:%M}";
        };
        cpu = {
          format = "  {usage}%";
          on-click = systemMonitor;
        };
        memory = {
          format = " {}%";
          interval = 5;
          on-click = systemMonitor;
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = ["" "" "" "" "" "" "" "" "" ""];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
        };
        backlight = {
          tooltip = false;
          format = "{icon} {percent}%";
          # format-icons = ["" "" "" "" "" "" ""];
          on-scroll-up = "${brightnessctl} s 1%-";
          on-scroll-down = "${brightnessctl} s +1%";
        };
        network = {
          interval = 3;
          format-wifi = " ";
          format-ethernet = "";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = "";
        };
        "custom/menu" = {
          format = " ";
          on-click = "${launcher}";
        };
      };
    };
  };
}
