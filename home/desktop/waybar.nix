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
        font-family: Material Design Icons, monospace;
        font-size: 13px;
      }

      window#waybar {
        background-color: #${base00};
        transition-property: background-color;
        transition-duration: 0.5s;
       }

      #workspaces {
        background-color: #${base01};
        margin: 0 4px;
        color: #${base04};
        border-radius: 4px;
        padding: 0 6px;
      }

      #workspaces button {
      }

      #workspaces button.visible {
      }

      #workspaces button.active {
      }

      #workspaces button.urgent {
        color: rgba(238, 46, 36, 1);
      }

      #tray {
        margin: 4px 16px 4px 4px;
        border-radius: 4px;
        background-color: #${base02};
      }

      #tray * {
        padding: 0 6px;
        border-left: 1px solid #${base00};
      }

      #tray *:first-child {
        border-left: none;
      }

      #submap, #clock, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #backlight, #custom-menu, #clock, #temperature, #tray {
        margin: 4px 2px;
        min-width: 20px;
        border-radius: 4px;
        background-color: #${base01};
        padding: 0 6px;
      }

      #pulseaudio.muted {
        color: #${base0F};
      }

      #pulseaudio.bluetooth {
        color: #${base0C};
      }

      #clock {
        margin-left: 12px;
        margin-right: 4px;
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
    systemd.enable = true;
    settings = {
      primary = {
        layer = "top";
        height = 28;
        margin = "6";
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
          on-click = "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";
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
