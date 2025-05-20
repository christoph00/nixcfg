# #
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  pkgs,
  flake,
  lib,
  ...
}:
let
  inherit (flake.lib) enabled;
in
{
  imports = [ flake.modules.nixos.host ];
  facter.reportPath = ./facter.json;
  networking.hostName = "tower";
  hw.cpu = "intel";
  hw.gpu = "amd";
  hw.ram = 32;
  host.graphical = true;
  host.gaming = true;

  svc.actions-runner = enabled;

  desktop.enable = true;
  desktop.remote = true;
  desktop.gaming = enabled;
  desktop.autologin = true;

  sys.boot.secureBoot = true;
  sys.disk.device = "/dev/nvme0n1";
  sys.disk.encrypted = true;

  services.pyload.enable = true;
  services.pyload.listenAddress = "0.0.0.0";
  services.pyload.downloadDirectory = "/media/ssd-data/Downloads";
  services.pyload.user = "christoph";
  services.pyload.group = "users";

  services.nzbget = {
    enable = true;
    user = "christoph";
    group = "users";
    settings = {
      MainDir = "/media/ssd-data/Downloads";
    };

  };

  sys.state.directories = [
    "/var/lib/pyload"
    "/var/lib/nzbget"
  ];
  networking.firewall.allowedTCPPorts = [
    8000
    6789
  ];

  # internal.services.nas = {
  #   enable = true;
  #   domain = "tdata.r505.de";
  #   extraDirectorys = [
  #     "/media/Games"
  #     "/media/ssd-data"
  #     "/media/hdd-data"
  #   ];
  # };
  #
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
      amdvlk
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
    legacySupport.enable = true;
    amdvlk.enable = true;
    amdvlk.support32Bit.enable = true;
  };

  environment.variables = {
    # RADV_PERFTEST = "sam,video_decode,transfer_queue";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";

    # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

    VK_DRIVER_FILES = lib.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
      "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json"
    ];

    VK_ICD_FILENAMES = lib.concatStringsSep ":" [
      "${pkgs.mesa}/share/vulkan/icd.d/radeon_icd.x86_64.json" # Mesa RADV 64-bit
      "${pkgs.driversi686Linux.mesa}/share/vulkan/icd.d/radeon_icd.i686.json" # Mesa RADV 32-bit
    ];

    AMD_VULKAN_ICD = "RADV";

    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
    "amdgpu"
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
  boot.blacklistedKernelModules = [ "fglrx" ];
  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "amdgpu"
    ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="13"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource2_resize}="3"
  '';

}
