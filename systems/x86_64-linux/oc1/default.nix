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

  networking.hostName = "oc1";

  ${namespace}.meta = {
    type = "server";
    primaryNic = "ens3";
  };

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "nvme"
  ];

  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "24.05";
}
