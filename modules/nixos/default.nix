{lib, ...}:
with lib; {
  options.nos = {
    type = mkOption {
      type = types.enum ["laptop" "desktop" "server" "vm"];
    };
    hw = {
      cpu = mkOption {
        type = types.enum ["intel" "vm-intel" "amd" "vm-amd" null];
        default = null;
      };
      gpu = mkOption {
        type = types.enum ["amd" "intel" "nvidia" "hybrid-nv" "hybrid-amd" null];
        default = null;
      };
      monitors = mkOption {
        type = types.listOf types.string;
        default = [];
      };
      netifs = mkOption {
        type = types.listOf types.string;
        default = [];
      };
    };
    mainUser = mkOption {
      type = types.str;
    };
    audio = {
      enable = mkEnableOption "audio";
    };
    video = {
      enable = mkEnableOption "video";
    };
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };
    printing = {
      enable = mkEnableOption "printing";
    };
    kernel = mkOption {
      type = types.raw;
      default = pkgs.linuxPackages_latest;
    };
    bootloader = mkOption {
      type = types.enum ["none" "grub" "systemd-boot"];
      default = "systemd-boot";
    };
    persist = {
      enable = mkEnableOption "rollback root";
      rootOnTmpfs = mkEnableOption "mount root on tmpfs";
      stateDir = mkOption {
        type = types.str;
      };
    };
    network = {
      manager = mkOption {
        type = types.enum ["networkd" "network-manager" null];
        default = "networkd";
      };
      tailscale = mkEnableOption "persist root";
      tweaks = mkEnableOption "network tweaks";
    };
    containers = mkEnableOption "containers";

    desktop = {
      enable = mkEnableOption "desktop";
      wm = mkOption {
        type = types.enum ["hyprland" "xfce"];
        default = "hyprland";
      };
      autologin = mkOption {
        type = types.bool;
        default = false;
      };
      enableHomeManager = mkOption {
        type = types.bool;
        default = false;
      };
      gaming = mkEnableOption "gaming";
    };
  };

  config = {
  };
}
