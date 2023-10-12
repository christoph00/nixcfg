{
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
  options.chr.system.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to configure filesystems.";
    persist = mkBoolOpt false "rollback root";
    rootOnTmpfs = mkBoolOpt false "mount root on tmpfs";
    stateDir = mkOption {
      type = types.str;
      default = "/nix/persist";
    };
    btrfs = mkBoolOpt false "btrfs layout";
    mainDisk = mkOption {
      type = types.str;
      default = "/dev/sda2";
    };
    efiDisk = mkOption {
      type = types.str;
      default = "/dev/disk/by-label/UEFI";
    };
    swapDevice = mkOption {
      type = types.str;
      default = "/dev/sda3";
    };
  };

  config = mkIf cfg.enable {
    fileSystems = let
      device = cfg.mainDisk;
    in {
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

      "/nix" = mkIf cfg.btrfs {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@nix" "noatime" "compress-force=zstd"];
      };

      "/boot" = {
        device = cfg.efiDisk;
        fsType = "vfat";
      };

      "${cfg.stateDir}" = mkIf cfg.btrfs {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@persist" "noatime" "compress-force=zstd"];
        neededForBoot = true;
      };

      "/home" = mkIf cfg.btrfs {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@home" "noatime" "compress-force=zstd"];
      };
    };
  };
}
