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
    imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "oc1";

  ${namespace} = {
    type = "server";
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    # efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = ["nvme"];

  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "xfs";
  };
  swapDevices = [{device = "/dev/sda2";}];

  networking.interfaces.ens3.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "24.05";
}