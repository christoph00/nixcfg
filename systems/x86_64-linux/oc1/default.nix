{ ... }:
{
  facter.reportPath = ./facter.json;

  networking.hostName = "oc1";

  internal.type = "vm";
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.swapSize = "1G";
  internal.system.fs.tmpRoot = false;

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "nvme"
  ];

  system.stateVersion = "24.11";
}
