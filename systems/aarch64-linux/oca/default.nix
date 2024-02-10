{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  inherit (inputs) nixos-hardware;
in {
  networking.hostName = "oca";

  chr = {
    type = "vm";
    system.boot.efi = true;
    system.boot.bootloader = "grub";
    system.filesystem = {
      enable = true;
      btrfs = true;
      persist = true;
      mainDisk = "/dev/sda3";
      efiDisk = "/dev/sda1";
      rootOnTmpfs = true;
    };
  };

  networking.interfaces.eth0.useDHCP = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"];
  boot.kernelParams = ["net.ifnames=0"];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
    };
  };

  swapDevices = [
    {device = "/dev/sda2";}
  ];

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "23.11";
}
