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

    roles = [
      "router"
      "nas"
      "media"
      "smart-home"
    ];

    services.router = {
      internalInterface = "enp1s0";
      externalInterface = "enp2s0f1";
    };

    services.webserver.enable = true;

  };

  boot.kernelModules = [
    #"kvm-intel"
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
    (config.boot.kernelPackages.r8168.overrideAttrs (
      _: super: rec {
        version = "8.054.00";
        src = pkgs.fetchFromGitHub {
          owner = "mtorromeo";
          repo = "r8168";
          rev = version;
          sha256 = "sha256-KyycAe+NBmyDDH/XkAM4PpGvXI5J1CuMW4VuHcOm0UQ=";
        };
        meta = super.meta // {
          broken = false;
        };
      }
    ))
  ];
  boot.blacklistedKernelModules = [ "r8169" ];

  system.stateVersion = "24.05";
}
