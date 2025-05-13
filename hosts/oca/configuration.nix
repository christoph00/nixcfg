{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.host ];

  networking.hostName = "oca";
  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;

  host.vm = true;

  networking.timeServers = [ "169.254.169.254" ];

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
    "usbhid"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
  ];

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = "aarch64-linux";
}
