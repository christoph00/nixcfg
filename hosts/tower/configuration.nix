# #
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  pkgs,
  flake,
  lib,
  config,
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
  desktop.gaming.enable = true;
  #desktop.remote = false;
  #desktop.autologin = true;

  sys.boot.secureBoot = false;
  sys.disk.device = "/dev/nvme0n1";
  sys.disk.encrypted = true;

  age.secrets.tower-root-key = flake.lib.mkSecret { file = "tower-root-key"; };
  boot.initrd.secrets."/root.key" = config.age.secrets.tower-root-key.path;
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    keyFile = "/root.key";
    keyFileTimeout = 10;
    allowDiscards = true;
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
        "space_cache=v2"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.amdgpu_top
    pkgs.libva-utils
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

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
    overdrive = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  #services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "i2c_dev"
  ];
  boot.kernelParams = [
    # "mem_sleep_default=deep"
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
    "random.trust_cpu=on"
    # ttm.pages_limit=2097152 = 8GB GTT (GART), ersetzt deprecated amdgpu.gttsize=8192
    "ttm.pages_limit=2097152"
    # intremap=no_x2apic_optout: BIOS blockiert x2APIC, hiermit erzwingen
    "intremap=no_x2apic_optout"
    # pci=realloc=off: Stabil, kein Above 4G im BIOS
    "pci=realloc=off"
  ];
  boot.blacklistedKernelModules = ["fglrx"];
  boot.initrd.kernelModules = [ "vfat" "nls_cp437" "nls_ascii" "nls_utf8" ];
  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbcore"
      "usb_storage"
      "usbhid"
      "uas"
      "vfat"
    ];
  };

  # RBAR (Resizable BAR) für RX580: BAR0 auf 8GB setzen (2^13 MB)
  # Initrd udev rule: feuert vor amdgpu Treiber-Load, damit resize nicht scheitert
  boot.initrd.services.udev.packages = [
    (pkgs.writeTextFile {
      name = "99-rbar.rules";
      text = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="13"
      '';
      destination = "/etc/udev/rules.d/99-rbar.rules";
    })
  ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="13"
  '';

  # === Test: nspawn-Container smart-home ===
  virt.containers = {
    enable = true;
    bridge = "br-cnt";
    subnet = "10.88.0.0/24";
    hostAddress = "10.88.0.1";
    externalInterface = "enp2s0";
    instances = {
      smart-home = {
        ip = "10.88.0.10";
      };
    };
  };
}
