# #
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  pkgs,
  ...
}:
{
  # imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  facter.reportPath = ./facter.json;

  networking.hostName = "tower";

  internal.type = "desktop";
  internal.isV3 = true;
  internal.system.boot.secureBoot = true;
  internal.services.nas = {
    enable = true;
    domain = "tdata.r505.de";
    extraDirectorys = [
      "/media/Games"
      "/media/ssd-data"
      "/media/hdd-data"
    ];
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

  environment.systemPackages = [
    pkgs.amdgpu_top
    pkgs.libva-utils
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      libvdpau-va-gl
      vaapiVdpau
      #rocmPackages.clr.icd
      vulkan-loader
      vulkan-extension-layer
      vulkan-validation-layers
      mangohud
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
      mangohud
    ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.amdgpu = {
    amdvlk = {
      enable = true;
      supportExperimental.enable = true;
      support32Bit.enable = true;
      settings = {
        AllowVkPipelineCachingToDisk = 1;
        EnableVmAlwaysValid = 1;
        IFH = 0;
        IdleAfterSubmitGpuMask = 1;
        ShaderCacheMode = 1;
      };
    };
    opencl.enable = true;
    initrd.enable = true;
  };

  environment.variables = {
    RADV_PERFTEST = "sam,video_decode,transfer_queue";
    AMD_VULKAN_ICD = "RADV";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
  ];
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amdgpu.gttsize=8192"
    "amdgpu.ignore_crat=1"
  ];

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "amdgpu"
    ];
  };

  services.udev.extraRules = ''
    #GPU bar size
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="8"
  '';

  system.stateVersion = "24.05";
}
