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
      persist = true;
      efiDisk = "/dev/sda1";
      rootOnTmpfs = true;
    };
  };

  networking.interfaces.eth0.useDHCP = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "usbhid"];
  boot.kernelParams = ["net.ifnames=0"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
    };
  };

  fileSystems."/nix" = {
    device = "/dev/sdb3";
    fsType = "ext4";
    neededForBoot = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  system.stateVersion = "23.11";
}
