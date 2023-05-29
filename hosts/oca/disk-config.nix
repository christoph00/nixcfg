{disks ? ["/dev/vda"], ...}: {
  disk = {
    nodev = {
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };
    };
    main = {
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
