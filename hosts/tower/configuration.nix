# #
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  pkgs,
  flake,
  lib,
  perSystem,
  ...
}: let
  inherit (flake.lib) enabled;
in {
  imports = [flake.modules.nixos.host];
  facter.reportPath = ./facter.json;
  networking.hostName = "tower";
  hw.cpu = "intel";
  hw.gpu = "amd";
  hw.ram = 32;
  host.graphical = true;
  host.gaming = true;

  desktop.enable = true;
  desktop.remote = false;
  desktop.autologin = true;

  sys.boot.secureBoot = false;
  sys.disk.device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12PNEAD417298N";
  sys.disk.encrypted = true;

  services.sabnzbd = enabled;

  boot.initrd.systemd.mounts = [
    {
      what = "/dev/disk/by-label/KEYSEC";
      where = "/keysec";
      type = "vfat";
    }
  ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    keyFile = "/keysec/root.key";
    keyFileTimeout = 5;
    # fallbackToPassword = true;
  };

  fileSystems = {
    "/media/Games" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = [
        "subvol=@games"
        "noatime"
        "compress-force=zstd"
      ];
    };

    "/media/ssd-data" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = [
        "subvol=@data"
        "noatime"
        "compress-force=zstd"
      ];
    };

    "/media/hdd-data" = {
      device = "/dev/disk/by-uuid/25fc5836-72df-4881-8760-af49333fa485";
      fsType = "btrfs";
      options = [
        "subvol=@data"
        "noatime"
        "compress-force=zstd"
      ];
    };
  };

  services.lact.enable = true;
  sys.state.directories = ["/etc/lact"];

  environment.systemPackages = [
    pkgs.amdgpu_top
    pkgs.libva-utils
    pkgs.lact
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      vulkan-loader
      vulkan-extension-layer
      vulkan-validation-layers
    ];
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # WireGuard configuration
  network.wireguard = {
    enable = false;
    ip = "10.100.100.105";
    publicKey = "6CTpNoM92SEBu6LFMYs2dZNoOA/6Ad00a22NITmsH1w=";
  };

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
    overdrive = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "i915"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
  ];
  boot.kernelParams = [
    # "mem_sleep_default=deep"
    "amdgpu.gttsize=8192"
    "amdgpu.ignore_crat=1"
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];
  boot.blacklistedKernelModules = ["fglrx"];
  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
    ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="13"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource2_resize}="3"
  '';
}
