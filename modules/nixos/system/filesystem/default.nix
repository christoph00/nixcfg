{
  inputs,
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.filesystem;
in {
  imports = [inputs.disko.nixosModules.disko];
  options.chr.system.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to configure filesystems.";
    disko = mkBoolOpt false "Enable Disko config";
    persist = mkBoolOpt false "rollback root";
    rootOnTmpfs = mkBoolOpt false "mount root on tmpfs";
    stateDir = mkOption {
      type = types.str;
      default = "/nix/persist";
    };
    btrfs = mkBoolOpt false "btrfs layout";
    ext4 = mkBoolOpt false "ext4 layout";
    mainDisk = mkOption {
      type = types.str;
      default = "/dev/sda2";
    };
    efiDisk = mkOption {
      type = types.str;
      default = "/dev/disk/by-label/UEFI";
    };
    bootType = mkOption {
      type = types.str;
      default = "vfat";
    };
    swapDevice = mkOption {
      type = types.str;
      default = "/dev/sda3";
    };
    swap = mkBoolOpt' false;
    swapSize = mkOpt' str "8G";
    home = mkBoolOpt true "Enable Home Partition";
    extraDisks = mkOpt attrs {} "Extra Disks (Disko config).";
    extraSubvolumes = mkOpt attrs {} "Extra Subvolumes for the Main Disk";
  };

  config = let
    device = cfg.mainDisk;
  in
    mkIf cfg.enable {
      fileSystems = {
        "/" = mkIf cfg.rootOnTmpfs {
          device = "none";
          fsType = "tmpfs";
          options = ["defaults" "size=2G" "mode=755"];
        };
        # else {
        #   inherit device;
        #   fsType = "btrfs";
        #   options = ["subvol=@root" "noatime" "compress-force=zstd"];
        # };

        "/nix" = mkIf (cfg.btrfs && !cfg.disko) {
          inherit device;
          fsType = "btrfs";
          options = ["subvol=@nix" "noatime" "compress-force=zstd"];
        };

        "/boot" = mkIf (!cfg.disko && !config.chr.system.boot.efi && cfg.btrfs) {
          device = cfg.efiDisk;
          fsType = "btrfs";
          tions = mkIf (!cfg.disko && !config.chr.system.boot.efi && cfg.btrfs) ["subvol=@boot" "noatime" "compress-force=zstd"];
        };

        "${cfg.stateDir}" = mkIf (cfg.btrfs && cfg.persist) {
          device = mkIf (!cfg.disko) device;
          fsType = mkIf (!cfg.disko) "btrfs";
          options = mkIf (!cfg.disko) ["subvol=@persist" "noatime" "compress-force=zstd"];
          neededForBoot = true;
        };

        "/home" = mkIf (cfg.btrfs && !cfg.disko) {
          inherit device;
          fsType = cfg.bootType;
          options = ["subvol=@home" "noatime" "compress-force=zstd"];
        };
      };

      disko.devices =
        mkIf cfg.disko {
          disk.mainDisk = {
            type = "disk";
            inherit device;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  label = "ESP";
                  type = "EF00";
                  priority = 1;
                  size = "512M";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                swap = mkIf cfg.swap {
                  label = "swap";
                  type = "8200";
                  size = cfg.swapSize;
                  content = {
                    type = "swap";
                    resumeDevice = true; # resume from hiberation from this device
                  };
                };
                root = mkIf cfg.btrfs {
                  label = "root";
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"]; # Override existing partition
                    # Subvolumes must set a mountpoint in order to be mounted,
                    # unless their parent is mounted
                    subvolumes =
                      {
                        # Subvolume name is different from mountpoint
                        "@root" = mkIf (!cfg.rootOnTmpfs) {
                          mountpoint = "/";
                        };
                        # Mountpoints inferred from subvolume name
                        "@home" = mkIf cfg.home {
                          mountpoint = "/home";
                          mountOptions = ["compress-force=zstd"];
                        };
                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = ["compress-force=zstd" "noatime"];
                        };
                        "@persist" = mkIf cfg.persist {
                          mountpoint = "${cfg.stateDir}";
                          mountOptions = ["compress-force=zstd" "noatime"];
                        };
                      }
                      // cfg.extraSubvolumes;
                  };
                };
              };
            };
          };
        }
        // cfg.extraDisks;
    };
}
