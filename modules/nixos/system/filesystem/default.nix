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
      default = "/dev/disk/by-label/UEFI";
    };
    swapDevice = mkOption {
      type = types.str;
      default = "/dev/sda3";
    };
  };

  config = mkIf cfg.enable {
    "/" =
      if config.chr.system.filesystem.rootOnTmpfs
      then {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=2G" "mode=755"];
      }
      else {
        inherit device;
        fsType = "btrfs";
        options = ["subvol=@root" "noatime" "compress-force=zstd"];
      };

    "/nix" = {
      inherit device;
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress-force=zstd"];
    };

    "/boot" = {
      device = chr.system.filesystem.efiDisk;
      fsType = "vfat";
    };

    "${config.chr.system.filesystem.stateDir}" = {
      inherit device;
      fsType = "btrfs";
      options = ["subvol=@persist" "noatime" "compress-force=zstd"];
      neededForBoot = true;
    };

    "/home" = {
      inherit device;
      fsType = "btrfs";
      options = ["subvol=@home" "noatime" "compress-force=zstd"];
    };
  };
}
