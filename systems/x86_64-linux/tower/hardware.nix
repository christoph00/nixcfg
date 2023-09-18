{}:{
  fileSystems = {
    "/media/Games" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@games" "noatime" "compress-force=zstd"];
    };

    "/media/ssd-data" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@data" "noatime" "compress-force=zstd"];
    };

    # "/media/hdd-data" = {
    #   device = "/dev/disk/by-uuid/25fc5836-72df-4881-8760-af49333fa485";
    #   fsType = "btrfs";
    #   options = ["subvol=@data" "noatime" "compress-force=zstd"];
    # };

 /*    "/media/ncdata" = {
      device = "/dev/disk/by-label/ssd-data";
      options = ["subvol=@ncdata" "discard=async" "compress-force=zstd" "nofail"];
    }; */
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd = {
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    kernelModules = ["amdgpu"];
  };
}
