{disks ? ["/dev/sda"], ...}: {
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "1MiB";
              end = "128MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              start = "128MiB";
              end = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@root" = {
                    mountpoint = "/";
                  };
                  # Mountpoints inferred from subvolume name
                  "@home" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };
                  "@persist" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix/persist";
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
