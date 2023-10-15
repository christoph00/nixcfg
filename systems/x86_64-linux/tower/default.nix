{
  pkgs,
  config,
  lib,
  channel,
  ...
}:
with lib;
with lib.chr; {

  chr = {
    type = "desktop";
  };
  chr.system.filesystem = {
    enable = mkDefault true;
    btrfs = mkDefault true;
    persist = mkDefault true;
    mainDisk = mkDefault "/dev/nvme0n1p3";
    efiDisk = mkDefault "/dev/nvme0n1p1";
    rootOnTmpfs = mkDefault true;
  };

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
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd = {
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    kernelModules = ["amdgpu"];
  };
}
