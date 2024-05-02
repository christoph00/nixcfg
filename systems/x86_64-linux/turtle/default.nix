{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
with lib;
with lib.chr;
let
  inherit (inputs) nixos-hardware;
in
{
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
      rootOnTmpfs = true;
      bootType = "btrfs";
      efiDisk = "/dev/vda2";
    };
    system.boot = {
      enable = true;
      bootloader = "grub";
      efi = false;
    };
  };

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/vda";
      configurationLimit = 5;
    };
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "ahci"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.accept_ra" = lib.mkForce "0";
    "net.ipv6.default.accept_ra" = lib.mkForce "0";
  };

  networking = {
    defaultGateway6 = {
      address = "2a01:4f8:231:f400:2::2";
      interface = "ens3";
    };

    interfaces.ens3.ipv6.addresses = [
      {
        address = "2a01:4f8:231:f426::a";
        prefixLength = 64;
      }
      {
        address = "2a01:4f8:231:f426::b";
        prefixLength = 64;
      }
    ];
    interfaces.ens3.ipv6.routes = [
      {
        address = "2a01:4f8:231:f426::";
        prefixLength = 64;
      }
      {
        address = "2a01:4f8:162:6343::2";
        prefixLength = 0;
      }
    ];
    nameservers = [
      "2a01:4f9:c010:3f02::1"
      "2a01:4f8:c2c:123f::1"
      "2a01:4f8:c2c:123f:69::1"
      "2a01:4f9:c010:3f02:69::1"
    ];
  };

  # systemd.network.networks."20-ens3" = {
  #   name = "ens3";
  #   DHCP = "no";
  #   dns = [
  #     "2a01:4f8:c2c:123f::1"
  #   ];
  #   addresses = [
  #     {addressConfig.Address = "2a01:4f8:231:f426::a/64";}
  #   ];
  #   routes = [
  #     {
  #       routeConfig.Gateway = "2a01:4f8:162:6343::2";
  #       routeConfig.GatewayOnLink = true;
  #     }
  #     {routeConfig.Destination = "2a01:4f8:231:f426::/64";}
  #     {routeConfig.Destination = "2a01:4f8:162:6343::2";}
  #   ];
  # };

  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "23.11";
}
