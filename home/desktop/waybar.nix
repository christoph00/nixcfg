{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Dependencies
  jq = "${pkgs.jq}/bin/jq";
  gamemoded = "${pkgs.gamemode}/bin/gamemoded";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  btm = "${pkgs.bottom}/bin/btm";
  wofi = "${pkgs.wofi}/bin/wofi";
  #hyprctl = "${inputs.hyprland.packages.${pkgs.system}.default}/bin/hyprctl";
  terminal = "${pkgs.wezterm}/bin/wezterm";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

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


      #workspaces button.visible {
      }

      #workspaces button.active {
      }

      #workspaces button.urgent {
        color: rgba(238, 46, 36, 1);
      }

      #tray {
        margin: 4px 2px;
        border-radius: 2px;
        background-color: #${base02};
      }

      #tray * {
        padding: 0 6px;
        border-left: 1px solid #${base00};
      }

      #tray *:first-child {
        border-left: none;
      }

      #workspaces, #submap, #clock, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #backlight, #custom-menu, #clock, #temperature, #tray {
        margin: 4px 2px;
        min-width: 20px;
        border-radius: 2px;
        background-color: #${base01};
        padding: 0 6px;
      }

      #pulseaudio.muted {
        color: #${base0F};
      }

      #pulseaudio.bluetooth {
        color: #${base0C};
      }


      #temperature.critical {
        color: #${base0F};
      }

    '';

  # Function to simplify making waybar outputs
  jsonOutput = name: {
    pre ? "",
    text ? "",
    tooltip ? "",
    alt ? "",
    class ? "",
    percentage ? "",
  }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
    set -euo pipefail
    ${pre}
    ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
  ''}/bin/waybar-${name}";
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
    systemd.enable = true;
    settings = {
      primary = {
        layer = "top";
        height = 32;
        margin = "2";
        position = "top";

        #output = builtins.map (m: m.name) (builtins.filter (m: m.isSecondary == false) config.monitors);
        modules-left = [
          "custom/menu"
          "wlr/workspaces"
          "hyprland/submap"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "backlight"
          "network"
          "temperature"
          "cpu"
          "memory"
          "battery"
          "tray"
          "clock"
        ];

        "wlr/workspaces" = {
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
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
          };
          on-click = "${pkgs.fuzzel}/bin/fuzzel";
        };
        "custom/hostname" = {
          exec = "echo $USER@$(hostname)";
          on-click = terminal;
        };
        "custom/gamemode" = {
          exec-if = "${gamemoded} --status | grep 'is active' -q";
          interval = 2;
          return-type = "json";
          exec = jsonOutput "gamemode" {
            tooltip = "Gamemode is active";
          };
          format = " ";
        };
      };
    };
  };
}
