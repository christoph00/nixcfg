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

  internal.type = "server";
  internal.isV3 = true;
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.swapSize = "1G";
  internal.system.fs.device = "/dev/mmcblk0";

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
    ];
  };

  system.stateVersion = "24.05";
}
