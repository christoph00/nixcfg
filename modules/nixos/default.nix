{
  lib,
  pkgs,
  hostname,
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
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "DP-1";
            };
            isPrimary = mkOption {
              type = types.bool;
              default = true;
            };
            width = mkOption {
              type = types.int;
              default = 1920;
            };
            height = mkOption {
              type = types.int;
              default = 1080;
            };
            refreshRate = mkOption {
              type = types.int;
              default = 60;
            };
            x = mkOption {
              type = types.int;
              default = 0;
            };
            y = mkOption {
              type = types.int;
              default = 0;
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
            workspace = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
            };
          };
        });
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
      enable = mkOption {
        type = types.bool;
        default = config.nos.desktop.enable;
      };
    };
    video = {
      enable = mkOption {
        type = types.bool;
        default = config.nos.desktop.enable;
      };
    };
    bluetooth = {
      enable = mkOption {
        type = types.bool;
        default = config.nos.desktop.enable;
      };
    };
    printing = {
      enable = mkOption {
        type = types.bool;
        default = config.nos.desktop.enable;
      };
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
      tweaks = mkEnableOption "network tweaks";
      manager = mkOption {
        type = types.enum ["networkd" "network-manager" null];
        default = "networkd";
      };
      domain = mkOption {
        type = types.str;
        default = "${hostname}.net.r505.de";
      };
      tailscale = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };
    containers = mkEnableOption "containers";

    services = {
      nas = {
        enable = mkEnableOption "enable nas";
        domain = mkOption {
          type = types.str;
          default = "data.${config.nos.network.domain}";
        };
      };
      smart-home = mkEnableOption "smart home";
      home-assistant = {
        enable = mkOption {
          type = types.bool;
          default = config.nos.services.smart-home;
        };
        domain = mkOption {
          type = types.str;
          default = "ha.${config.nos.network.domain}";
        };
      };
    };

    enableHomeManager = mkOption {
      type = types.bool;
      default = config.nos.desktop.enable;
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
        monospace = mkFontOption "monospace";
        regular = mkFontOption "regular";
      };
    };
  };

  imports = [
    ./system
    ./desktop
    #  ./services
  ];
}
