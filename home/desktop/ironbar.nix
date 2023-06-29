{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs.ironbar = {
    enable = true;
    systemd = true;
    package = inputs.ironbar.packages.x86_64-linux.default.overrideAttrs (old: {
      patches = [./ironbar-nix-path.patch];
    });
    config = let
      menu = {
        type = "custom";
        name = "menu";
        bar = [
          {
            type = "image";
            src = "icon:application-menu";
            size = 24;
          }
        ];
      };

      launcher = {
        type = "launcher";
        # favorites = ["edge-browser" "wezterm"];
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
      tray = {type = "tray";};
      clock = {type = "clock";};
      sys-info = {
        format = [
          " {cpu_percent}%"
          # " {memory_used} / {memory_total} GB ({memory_percent}%)"
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
      end = [battery tray clock];
      style = ''
        * {
            font-family: Noto Sans Nerd Font, sans-serif;
            font-size: 16px;
            border: none;
        }
      '';
    };
  };
}
