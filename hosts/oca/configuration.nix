{
  inputs,
  lib,
  flake,
  ...
}:
let
  inherit (flake.lib) create-proxy enabled;
in
{
  imports = [ inputs.self.nixosModules.host ];

  networking.hostName = "oca";
  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;

  network.netbird.ip = "100.77.155.15";

  hw.cpu = "other";

  host.vm = true;
  shell.devtools = enabled;

  services.searx = enabled;
  services.audiobookshelf = enabled;
  services.rss-bridge = enabled;
  services.pinchflat = enabled;
  services.litellm = enabled;

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
