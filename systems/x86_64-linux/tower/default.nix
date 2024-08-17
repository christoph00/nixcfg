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

  #internal.type = "desktop";
  internal.system.disk.disk = "/dev/nvme0n1";
  internal.system.disk.swapSize = "16G";

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
  ];

  system.stateVersion = "24.05";
}
