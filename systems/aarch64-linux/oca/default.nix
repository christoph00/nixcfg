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
  imports = [ (modulesPath + "/profiles/qemu-guest.nix")];

  networking.hostName = "oca";

  internal.type = "vm";
  internal.system.fs.device = "/dev/sda";
  internal.system.fs.tmpRoot = true;
  internal.system.boot.encryptedRoot = false;

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
    "usbhid"
    "xhci_pci" "virtio_pci" "virtio_scsi" 
  ];
  boot.kernelParams = ["net.ifnames=0"];
  boot.kernelPackages = pkgs.linuxPackages_latest;


  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "24.05";
}
