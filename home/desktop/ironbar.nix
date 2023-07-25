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

  scss = with config.colorscheme.colors; ''
    $base00: ${base00};
    $base01: ${base01};
    $base02: ${base02};
    $base03: ${base03};
    $base04: ${base04};
    $base05: ${base05};
    $base06: ${base06};
    $base07: ${base07};
    $base08: ${base08};
    $base09: ${base09};
    $base0A: ${base0A};
    $base0B: ${base0B};
    $base0C: ${base0C};
    $base0D: ${base0D};
    $base0E: ${base0E};
    $base0F: ${base0F};

    $base10: ${base10};
    $base11: ${base11};
    $base12: ${base12};
    $base13: ${base13};
    $base14: ${base14};
    $base15: ${base15};
    $base16: ${base16};
    $base17: ${base17};

  '';
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
      end = [battery tray clock];
    };
  };
  xdg.configFile."ironbar/style.css".text = with config.colorscheme.colors; ''
            @define-color base00 #${base00};
            @define-color base01 #${base01};
            @define-color base02 #${base02};
            @define-color base03 #${base03};
            @define-color base04 #${base04};
            @define-color base05 #${base05};
            @define-color base06 #${base06};
            @define-color base07 #${base07};
            @define-color base08 #${base08};
            @define-color base09 #${base09};
            @define-color base0A #${base0A};
            @define-color base0B #${base0B};
            @define-color base0C #${base0C};
            @define-color base0D #${base0D};
            @define-color base0E #${base0E};
            @define-color base0F #${base0F};

    * {
     all: unset;
    }

    #bar {

     background-color: alpha(@base05,0.7);
     border: 1px solid alpha(@base04,0.7);
     border-radius: 6px 6px 0px 0;
     padding: 4px;
    }

    .item {
      padding: 6px;
     border: 1px solid;
     background: @base03;
     color: @base04;
      border-radius: 5px;
     margin: 1px;
    }


    .item.focused {
     background: @base0E;
     color: @base06;
    }


  '';
}
