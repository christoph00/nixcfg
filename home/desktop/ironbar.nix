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
in {
  programs.ironbar = {
    enable = true;
    package = inputs.ironbar.packages.x86_64-linux.default;
    config = let
      launcher = {
        type = "launcher";
        favorites = ["chromium-browser" "foot"];
        show_names = false;
        show_icons = true;
        icon_theme = "Breeze";
      };

      workspaces = {
        type = "workspaces";
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
        type = "label";
        label = "BAT: {{500:cat /sys/class/power_supply/BAT0/capacity}}";
      };
    in {
      position = "bottom";
      anchor_to_edges = true;
      start = [workspaces];
      end = [tray battery clock];
    };
  };
  systemd.user.services.ironbar.Service.Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
}
