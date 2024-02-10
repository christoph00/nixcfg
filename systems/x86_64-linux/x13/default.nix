{
  pkgs,
  config,
  lib,
  channel,
  inputs,
  ...
}:
with lib;
with lib.chr; {
  imports = [inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.kernelParams = [
    "quiet"
    "pcie_port_pm=off"
    "i915.i915_enable_rc6=1"
    "i915.i915_enable_fbc=1"
    "i915.enable_psr=2"
    "i915.lvds_downclock=1"
    "i915.perf_stream_paranoid=0"
    "i915.semaphores=1"
    "rcutree.rcu_idle_gp_delay=1"
    "splash"
    "i915.fastboot=1"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
    "mem_sleep_default=deep"
    "ahci.mobile_lpm_policy=3"
  ];
  boot.kernelModules = ["kvm-intel"];

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  services.throttled = {
    enable = true;
  };
  services.thinkfan.enable = true;

  chr = {
    type = "laptop";
    gaming.enable = true;
    system.boot.efi = true;
  };
  chr.system.filesystem = {
    enable = true;
    btrfs = true;
    persist = true;
    mainDisk = "/dev/nvme0n1p3";
    efiDisk = "/dev/nvme0n1p1";
    rootOnTmpfs = true;
  };

  system.stateVersion = "23.11";
}
