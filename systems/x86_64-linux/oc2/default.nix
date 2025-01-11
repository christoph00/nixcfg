{
  ...
}:
{
  facter.reportPath = ./facter.json;

  networking.hostName = "oc2";

  internal.type = "vm";
  internal.system.fs.enable = false;
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.tmpRoot = false;
  internal.system.fs.swapSize = "1G";
  internal.fs.type = "xfs";

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "xfs";
  };
  swapDevices = [ { device = "/dev/sda2"; } ];

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "nvme"
  ];

  system.stateVersion = "24.11";
}
