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

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
  ];

  system.stateVersion = "24.05";
}
