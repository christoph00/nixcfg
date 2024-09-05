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

  networking.hostName = "tower";

  internal.type = "desktop";
  internal.isV3 = true;

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

  boot.initrd = {
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    kernelModules = ["amdgpu"];
  };

  services.xserver.videoDrivers = ["amdgpu"];

  system.stateVersion = "24.05";
}
