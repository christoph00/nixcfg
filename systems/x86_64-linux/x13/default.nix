{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  namespace,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "x13";

  internal.type = "laptop";
  internal.system.disk.disk = "/dev/nvme0n1";
  #internal.system.disk.swapSize = "16G";

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
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
    "mitigations=off"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  services.throttled = {
    enable = true;
  };

  services.thinkfan.enable = true;

  system.stateVersion = "24.05";
}
