{modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "star";

  internal.type = "vm";
  internal.system.fs.device = "/dev/ploop62670";
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.swapSize = "1G";

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];

  system.stateVersion = "24.11";
}
