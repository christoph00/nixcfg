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

  styleCSS = with config.colorScheme.colors;
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

      #mode, #clock, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #backlight, #custom-menu, #clock, #temperature {
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
          "idle_inhibitor"
          #"custom/currentplayer"
          #"custom/player"
        ];
        modules-center = [
          "hyprland/window"
          #"cpu"
          #    "custom/gpu"
          #"memory"
          #"pulseaudio"
          #    "custom/unread-mail"
          #"custom/gammastep"
          #    "custom/gpg-agent"
        ];
        modules-right = [
          "backlight"
          "network"
          #"custom/tailscale-ping"
          "battery"
          "tray"
          #"custom/hostname"
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
        "custom/gpu" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gpu" {
            text = "$(cat /sys/class/drm/card0/device/gpu_busy_percent)";
            tooltip = "GPU Usage";
          };
          format = "力  {}%";
          on-click = systemMonitor;
        };
        memory = {
          format = " {}%";
          interval = 5;
          on-click = systemMonitor;
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "";
            headset = "";
            portable = "";
            default = ["" "" ""];
          };
          on-click = pavucontrol;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "零";
            deactivated = "鈴";
          };
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = ["" "" "" "" "" "" "" "" "" ""];
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
        };
        "sway/window" = {
          max-length = 20;
        };
        backlight = {
          tooltip = false;
          format = "{icon} {percent}%";
          format-icons = ["󰋙" "󰫃" "󰫄" "󰫅" "󰫆" "󰫇" "󰫈"];
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
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
                status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | tail -1 | cut -d ':' -f6 | xargs))"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = " ";
            "deactivating" = " ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No players found" | cut -d '.' -f1)"'';
            alt = "$player";
            tooltip = "$player";
          };
          format = "{icon}";
          format-icons = {
            "No players found" = "ﱘ";
            "Celluloid" = "";
            "spotify" = "阮";
            "ncspot" = "阮";
            "qutebrowser" = "爵";
            "discord" = "ﭮ";
            "sublimemusic" = "";
          };
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };
        "custom/player" = {
          exec-if = "${playerctl} status";
          exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}' '';
          return-type = "json";
          interval = 2;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "契";
            "Paused" = " ";
            "Stopped" = "栗";
          };
          on-click = "${playerctl} play-pause";
        };
      };
    };
  };
}
