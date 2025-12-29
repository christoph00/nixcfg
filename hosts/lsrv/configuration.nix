{
  flake,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [flake.modules.nixos.host];
  facter.reportPath = ./facter.json;
  networking.hostName = "lsrv";

  sys = {
    boot.encryptedRoot = false;
    disk = {
      device = "/dev/mmcblk0";
      forceDevice = true;
    };
  };

  network.router = {
    enable = false;
    internalInterface = "enp1s0";
    externalInterface = "enp2s0f1";
  };

  services.home-assistant.enable = true;
  services.mosquitto.enable = true;

  # WireGuard configuration
  network.wireguard = {
    enable = false;
    ip = "10.100.100.110";
    publicKey = "/i1dR37XIw95bwSK3UJb/67AAOwh2nCDOdAGGgiUjmM=";
  };

  # svc.nas = {
  #   enable = true;
  #   domain = "data.r505.de";
  #   extraDirectorys = [ "/mnt/userdata" ];
  # };
  #
  boot = {
    kernelModules = [
      "kvm-intel"
      "acpi_call"
      "i2c_dev"
    ];

    initrd = {
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
    # extraModulePackages = [
    #   (config.boot.kernelPackages.r8168.overrideAttrs (
    #     _: super: rec {
    #       version = "8.055.00";
    #       src = pkgs.fetchFromGitHub {
    #         owner = "mtorromeo";
    #         repo = "r8168";
    #         rev = version;
    #         sha256 = "sha256-KyycAe+NBmyDDH/XkAM4PpGvXI5J1CuMW4VuHcOm0UQ=";
    #       };
    #       meta = super.meta // {
    #         broken = false;
    #       };
    #     }
    #   ))
    # ];
    blacklistedKernelModules = ["r8169"];
  };
  fileSystems = {
    "/mnt/state".device = lib.mkFoce "/dev/disk/by-label/ssd-data";
    "/mnt/userdata" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = [
        "subvol=@userdata"
        "noatime"
        "compress-force=zstd"
      ];
    };
  };
}
