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
    enable32Bit = true;
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
  };

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
    "amdgpu"
  ];
  boot.kernelParams = [
    "rcutree.rcu_idle_gp_delay=1"
    "mem_sleep_default=deep"
    "amdgpu.gartsize=4096"
    "adgpu.ignore_crat=1"
  ];

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  system.stateVersion = "24.05";
}
