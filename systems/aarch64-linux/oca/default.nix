{
  lib,
  pkgs,
  ...
}:
{
  facter.reportPath = ./facter.json;

  networking.hostName = "oca";

  internal.type = "vm";
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  internal.services.office-server.enable = true;
  internal.services.glance.enable = true;
  internal.services.vscode-tunnel.enable = true;

  services.tinyproxy.enable = true;
  services.tinyproxy.settings.Listen = "0.0.0.0";
  networking.firewall.allowedTCPPorts = [ 8888 ];

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
    "usbhid"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "24.05";
}
