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

  networking.hostName = "oca";

  internal.type = "vm";
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  
  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
  ];
boot.kernelPackages =  pkgs.linuxPackages_latest;
  system.stateVersion = "24.05";
}
