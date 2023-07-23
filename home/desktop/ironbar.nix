{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  getVolume =
    (pkgs.writeShellApplication {
      name = "volget";
      runtimeInputs = [pkgs.wireplumber];
      text = ''
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}'
      '';
    })
    + "/bin/volget";
in {
  programs.ironbar = {
    enable = true;
    systemd = true;
    package = inputs.ironbar.packages.x86_64-linux.default;
    config = let
      menu = {
        type = "custom";
        name = "menu";
        bar = [
          {
            type = "image";
            src = "icon:application-menu";
            size = 32;
          }
        ];
      };

      launcher = {
        type = "launcher";
        show_names = false;
        show_icons = true;
      };

      workspaces = {
        type = "workspaces";
        all_monitors = false;
        # name_map = let
        #   workspaces = lib.genAttrs (map (n: builtins.toString n) [1 2 3 4 5 6 7 8 9 10]);
        # in
        #   workspaces (_: "●");
      };
      volume = {
        transition_type = "slide_end";
        transition_duration = 350;
        type = "custom";
        bar = [
          {
            type = "slider";
            class = "scale";
            length = 100;
            max = 100;
            on_change = "!${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ $0%";
            on_scroll_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 2%-";
            on_scroll_up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 2%+";
            on_click_right = "pavucontrol";
            value = "100:${getVolume}";
            tooltip = "{{${getVolume}}}%";
          }
        ];
      };
      tray = {type = "tray";};
      clock = {type = "clock";};
      sys-info = {
        format = [
          " {cpu_percent}%"
          #" {memory_used} / {memory_total} GB ({memory_percent}%)"
          # "| {swap_used} / {swap_total} GB ({swap_percent}%)"
          # " {disk_used:/} / {disk_total:/} GB ({disk_percent:/}%)"
          # "李 {net_down:enp39s0} / {net_up:enp39s0} Mbps"
          # "猪 {load_average:1} | {load_average:5} | {load_average:15}"
          # " {uptime}"
        ];
        type = "sys_info";
      };
      battery = {
        type = "upower";
        format = "{percentage}%";
      };
    in {
      position = "bottom";
      icon_theme = "Fluent";
      anchor_to_edges = true;
      start = [menu launcher];
      end = [battery tray volume clock];
      style = with config.colorscheme.colors; ''

        @define-color color_bg #${base00};
        @define-color color_bg_dark #${base01};
        @define-color color_border #${base05};
        @define-color color_border_active #${base04};
        @define-color color_text #${base05};
        @define-color color_urgent #${base04};

        /* -- base styles -- */

        * {
          transition: 100ms ease;
          font-family: ${config.fontProfiles.monospace.family};
          font-size: 1.1rem;
          border: none;
          border-radius: 0;
        }

        box, menubar, button {
            background-color: @color_bg;
            background-image: none;
        }

        button, label {
            color: @color_text;
        }

        button:hover {
            background-color: @color_bg_dark;
        }

        #bar {
            border-top: 1px solid @color_border;
        }

        .popup {
            border: 1px solid @color_border;
            padding: 1em;
        }


        /* -- clipboard -- */

        .clipboard {
            margin-left: 5px;
            font-size: 1.1em;
        }

        .popup-clipboard .item {
            padding-bottom: 0.3em;
            border-bottom: 1px solid @color_border;
        }


        /* -- clock -- */

        .clock {
            font-weight: bold;
            margin-left: 5px;
        }

        .popup-clock .calendar-clock {
            color: @color_text;
            font-size: 2.5em;
            padding-bottom: 0.1em;
        }

        .popup-clock .calendar {
            background-color: @color_bg;
            color: @color_text;
        }

        .popup-clock .calendar .header {
            padding-top: 1em;
            border-top: 1px solid @color_border;
            font-size: 1.5em;
        }

        .popup-clock .calendar:selected {
            background-color: @color_border_active;
        }


        /* -- launcher -- */

        .launcher .item {
            margin-right: 4px;
        }

        .launcher .item:not(.focused):hover {
            background-color: @color_bg_dark;
        }

        .launcher .open {
            border-bottom: 1px solid @color_text;
        }

        .launcher .focused {
            border-bottom: 2px solid @color_border_active;
        }

        .launcher .urgent {
            border-bottom-color: @color_urgent;
        }

        .popup-launcher {
            padding: 0;
        }

        .popup-launcher .popup-item:not(:first-child) {
            border-top: 1px solid @color_border;
        }


        /* -- music -- */

        .music:hover * {
            background-color: @color_bg_dark;
        }

        .popup-music .album-art {
            margin-right: 1em;
        }

        .popup-music .icon-box {
            margin-right: 0.4em;
        }

        .popup-music .title .icon, .popup-music .title .label {
            font-size: 1.7em;
        }

        .popup-music .controls *:disabled {
            color: @color_border;
        }

        .popup-music .volume .slider slider {
            border-radius: 100%;
        }

        .popup-music .volume .icon {
            margin-left: 4px;
        }

        .popup-music .progress .slider slider {
            border-radius: 100%;
        }

        /* -- script -- */

        .script {
            padding-left: 10px;
        }


        /* -- sys_info -- */

        .sysinfo {
            margin-left: 10px;
        }

        .sysinfo .item {
            margin-left: 5px;
        }


        /* -- tray -- */

        .tray {
            margin-left: 10px;
        }


        /* -- workspaces -- */

        .workspaces .item.focused {
            box-shadow: inset 0 -3px;
            background-color: @color_bg_dark;
        }

        .workspaces .item:hover {
            box-shadow: inset 0 -3px;
        }


        /* -- custom: power menu -- */

        .popup-power-menu #header {
            font-size: 1.4em;
            padding-bottom: 0.4em;
            margin-bottom: 0.6em;
            border-bottom: 1px solid @color_border;
        }

        .popup-power-menu .power-btn {
            border: 1px solid @color_border;
            padding: 0.6em 1em;
        }

        .popup-power-menu #buttons > *:nth-child(1) .power-btn {
            margin-right: 1em;
        }

      '';
    };
  };
}
