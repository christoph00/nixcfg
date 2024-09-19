##
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  namespace,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "tower";

  internal.type = "desktop";
  internal.isV3 = true;
  internal.system.boot.secureBoot = true;
  internal.graphical.desktop.display-manager.enable = false;
  internal.graphical.desktop.headless.enable = true;

  environment.systemPackages = [ pkgs.amdgpu_top ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      libvdpau-va-gl
      vaapiVdpau
      rocmPackages.clr.icd
      # vulkan-loader
      # vulkan-extension-layer
      # vulkan-validation-layers
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

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
    "amdgpu"
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
    ];
  };

  system.stateVersion = "24.05";
}
