##
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
{
  facter.reportPath = ./facter.json;
  networking.hostName = "lsrv";
  internal = {

    type = "server";
    isV3 = true;
    system = {
      boot.encryptedRoot = false;
      fs = {
        swapSize = "1G";
        device = "/dev/mmcblk0";
      };
    };
    network.lanInterface = "enp1s0";

  };

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
  ];

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "mmc_block"
    ];
  };
  boot.extraModulePackages = [
    (config.boot.kernelPackages.r8168.overrideAttrs (_: super: rec {
      version = "8.054.00";
      src = pkgs.fetchFromGitHub {
        owner = "mtorromeo";
        repo = "r8168";
        rev = version;
        sha256 = "sha256-KyycAe+NBmyDDH/XkAM4PpGvXI5J1CuMW4VuHcOm0UQ=";
      };
      meta =
        super.meta
        // {
          broken = false;
        };
    }))
  ];
  boot.blacklistedKernelModules = [ "r8169" ];

  systemd.network.networks."20-modem" = {
    name = "enp2s0f1";
    networkConfig = {
      DHCP = "no";
    };
    address = [
      "10.10.1.2/24"
    ];
  };

  system.stateVersion = "24.05";
}
