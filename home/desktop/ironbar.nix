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
      clock = {
        type = "clock";
        format = "%H:%M";
        format_popup = "%d.%m.%Y %H:%M";
      };
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
      start = [workspaces];
      center = [menu];
      end = [battery tray volume clock];
    };
  };
  xdg.configFile."ironbar/style.css".text = with config.colorscheme.colors; ''
    * {
      color: #${base01};
    }

    button:hover {
      background: #${base04};
    }

    #bar {
      border-top: 1px solid #${base01};
      background: alpha(#${base04}, 0.95);
    }
  '';
}
