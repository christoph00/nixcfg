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
  networking.hostName = "turtle";

  chr = {
    type = "server";
    system.filesystem = {
      enable = true;
      btrfs = true;
      persist = true;
      mainDisk = "/dev/vda2";
      efiDisk = "/dev/vda1";
      rootOnTmpfs = true;
    };
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    # efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];

  networking = {
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };

    interfaces.ens3.ipv6.addresses = [
      {
        address = "2a01:4f8:231:f426::a";
        prefixLength = 64;
      }
    ];
    nameservers = [
      "2001:67c:2b0::4"
      "2001:67c:2b0::6"
      "2a01:4f9:c010:3f02::1"
      "2a00:1098:32c::1"
      "2001:4860:4860::64"
      "2001:4860:4860::6464"
      "2001:4860:4860:0:0:0:0:6464"
      "2001:4860:4860:0:0:0:0:64"
      "2606:4700:4700::64"
      "2606:4700:4700::6400"
      "2606:4700:4700:0:0:0:0:64"
      "2606:4700:4700:0:0:0:0:6400"
      "2a01:4f9:c010:3f02::1"
      "2a00:1098:2b::1"
      "2a01:4f8:c2c:123f::1"
      "2001:67c:27e4::64"
      "2001:67c:27e4:15::6411"
      "2001:67c:27e4:15::64"
      "2001:67c:27e4::60"
      "2a03:7900:2:0:31:3:104:161"
      "2602:fc23:18::7"
      "2a00:1098:2c::1"
      "2001:67c:2960::64"
      "2001:67c:2960::6464"
      "2001:67c:2b0::4"
      "2001:67c:2b0::6"
      "2a01:4f8:c2c:123f:69::1"
      "2a00:1098:2b:0:69::1"
      "2a01:4f9:c010:3f02:69::1"
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "23.11";
}
