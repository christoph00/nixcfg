{
  disk,
  espSize,
  swapSize,
}:

{
  internal.system.fs.xfs.enable = true;
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
                  extraArgs = [ "-f" ];
                  format = "xfs";
                  mountOptions = [
                    "defaults"
                    "relatime"
                    "nodiratime"
                  ];
                  mountpoint = "/mnt/state";
                  type = "filesystem";
                };
              };
            };
          };
        };
      };
    };
  };
}
