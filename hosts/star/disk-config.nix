{disks ? ["/dev/vda"], ...}: {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "1MiB";
              part-type = "primary";
              flags = [ "bios_grub" ];
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
                  "/@root" = {
                    mountpoint = "/";
                  };
                  "/@boot" = {
                    mountpoint = "/boot";
                  };
                  # Mountpoints inferred from subvolume name
                  "/@home" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/home";
                  };
                  "/@nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };
                  "/@persist" = {
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
}
