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

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    # extraPackages = with pkgs; [
    #   mesa.drivers
    # ];
    setLdLibraryPath = true;
  };

  environment.systemPackages = [pkgs.amdgpu_top];
  boot.kernelModules = ["kvm-intel" "acpi_call" "i2c_dev" "amdgpu"];
  boot.blacklistedKernelModules = ["dm_mod"];
  boot.kernelParams = [
    "quiet"
    "rcutree.rcu_idle_gp_delay=1"
    "splash"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
    "mem_sleep_default=deep"
    "amdgpu.gartsize=4096"
    "adgpu.ignore_crat=1"
  ];
}
