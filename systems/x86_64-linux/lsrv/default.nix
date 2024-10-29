##
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
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

  networking.hostName = "lsrv";
  internal = {

    type = "server";
    isV3 = true;
    system = {
      boot.encryptedRoot = false;
      fs = {
        swapSize = "1G";
        device = "/dev/mmcblk1";
      };
    };
  };

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
  ];

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "r8169"
      "mmc_block"
    ];
  };
  #boot.extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  #boot.blacklistedKernelModules = [ "r8169" ];

  system.stateVersion = "24.05";
}
