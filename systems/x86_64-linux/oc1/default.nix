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
  imports = with nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    common-pc
    common-pc-ssd
  ];
  networking.hostName = "oc1";

  chr = {
    type = "server";
    system.filesystem = {
      enable = true;
      persist = false;
      rootOnTmpfs = false;
    };
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

  system.stateVersion = "23.11";
}
