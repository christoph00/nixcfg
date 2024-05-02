{
  inputs,
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.filesystem;
in
{
  options.chr.system.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to configure filesystems.";
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
    extraSubvolumes = mkOpt attrs { } "Extra Subvolumes for the Main Disk";
  };

  config = mkIf cfg.enable {
    fileSystems =
      let
        device = cfg.mainDisk;
      in
      {
        "/" = mkIf cfg.rootOnTmpfs {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "size=2G"
            "mode=755"
          ];
        };
        # else {
        #   inherit device;
        #   fsType = "btrfs";
        #   options = ["subvol=@root" "noatime" "compress-force=zstd"];
        # };

        "/nix" = mkIf cfg.btrfs {
          inherit device;
          fsType = "btrfs";
          options = [
            "subvol=@nix"
            "noatime"
            "compress-force=zstd"
          ];
        };

        "/boot" = {
          device = cfg.efiDisk;
          fsType = "vfat";
        };

        "${cfg.stateDir}" = mkIf (cfg.btrfs && cfg.persist) {
          inherit device;
          fsType = "btrfs";
          options = [
            "subvol=@persist"
            "noatime"
            "compress-force=zstd"
          ];
          neededForBoot = true;
        };

        "/home" = mkIf cfg.btrfs {
          inherit device;
          fsType = "btrfs";
          options = [
            "subvol=@home"
            "noatime"
            "compress-force=zstd"
          ];
        };
      };
  };
}
