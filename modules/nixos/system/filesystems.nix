{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nos.fs.btrfs {
    fileSystems = let
      device = config.nos.fs.mainDisk;
    in {
      "/" =
        if config.nos.fs.rootOnTmpfs
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
        device = config.nos.fs.efiDisk;
        fsType = "vfat";
      };

      "${config.nos.fs.stateDir}" = {
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
  };
}
