{
  disk,
  espSize,
  swapSize,
}:

{
  internal.system.fs.btrfs.enable = true;
  disko.devices = {
    disk = {
      "${disk}" = {
        type = "disk";
        device = "/dev/${disk}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "${espSize}";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "${swapSize}";
              content = {
                type = "swap";
                resumeDevice = true;
                randomEncryption = true;
                priority = 100;
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/disk.key";
                settings = {
                  # keyFile = "/tmp/disk.key";
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/" = {
                      mountOptions = [
                        "subvol=@root"
                        "noatime"
                        "compress=zstd"
                      ];
                      mountpoint = "/";
                    };
                    "/state" = {
                      mountOptions = [
                        "subvol=@state"
                        "noatime"
                        "compress=zstd"
                      ];
                      mountpoint = "/state";
                    };
                    "/nix" = {
                      mountOptions = [
                        "subvol=@nix"
                        "noatime"
                        "compress=zstd"
                      ];
                      mountpoint = "/nix";
                    };
                    "/home" = {
                      mountOptions = [
                        "subvol=@home"
                        "noatime"
                        "compress=zstd"
                      ];
                      mountpoint = "/home";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
