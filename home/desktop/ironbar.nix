{
  inputs,
  pkgs,
  lib,
  ...
}: let
  dependencies = with pkgs; [
    brightnessctl
    pamixer
    coreutils
    hyprland
  ];
  script-battery = pkgs.writeShellScript "battery.sh" ''
    print 98
  '';
in {
  programs.ironbar = {
    enable = true;
    systemd = true;
    package = inputs.ironbar.packages.x86_64-linux.default.overrideAttrs (old: {
      patches = [./ironbar-nix-path.patch];
    });
    config = let
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
<<<<<<< HEAD
      start = [workspaces launcher];
      end = [battery tray sys-info clock];
||||||| parent of c64ff93 ()
      start = [workspaces];
      end = [battery clock];
=======
      start = [workspaces];
      end = [battery tray clock];
>>>>>>> c64ff93 ()
    };
  };
}
