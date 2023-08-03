{
  lib,
  pkgs,
  ...
}:
with lib; let
  mkFontOption = kind: {
    family = lib.mkOption {
      type = lib.types.str;
      default = "Fira Code";
      description = "Family name for ${kind} font profile";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fira-code;
      description = "Package for ${kind} font profile";
    };
  };
in {
  options.nos = {
    type = mkOption {
      type = types.enum ["laptop" "desktop" "server" "vm"];
    };
    hw = {
      cpu = mkOption {
        type = types.enum ["intel" "vm-intel" "amd" "vm-amd" "pi" null];
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
    fs = {
      persist = mkEnableOption "rollback root";
      rootOnTmpfs = mkEnableOption "mount root on tmpfs";
      stateDir = mkOption {
        type = types.str;
        default = "/nix/persist";
      };
      btrfs = mkEnableOption "btrfs layout";
      mainDisk = mkOption {
        type = types.str;
        default = "/dev/sda2";
      };
      efiDisk = mkOption {
        type = types.str;
        default = "/dev/sda1";
      };
      swapDevice = mkOption {
        type = types.str;
        default = "/dev/sda3";
      };
    };
    mainUser = mkOption {
      type = types.str;
      default = "christoph";
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
    network = {
      manager = mkOption {
        type = types.enum ["networkd" "network-manager" null];
        default = "networkd";
      };
      tailscale = mkOption {
        type = types.bool;
        default = true;
      };
      tweaks = mkEnableOption "network tweaks";
    };
    containers = mkEnableOption "containers";

    services = {
      home-assistant = {
        enable = mkEnableOption "desktop";
      };
    };

    enableHomeManager = mkOption {
      type = types.bool;
      default = false;
    };

    desktop = {
      enable = mkEnableOption "desktop";
      wm = mkOption {
        type = types.enum ["Hyprland" "xfce"];
        default = "Hyprland";
      };
      autologin = mkOption {
        type = types.bool;
        default = false;
      };

      gaming = mkEnableOption "gaming";
      fontProfiles = {
        enable = lib.mkEnableOption "Whether to enable font profiles";
        monospace = mkFontOption "monospace";
        regular = mkFontOption "regular";
      };
    };
  };

  config = {
  };

  imports = [
    ./system
    ./desktop
    #  ./services
  ];
}
