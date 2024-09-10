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
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      pkgs.rocmPackages.clr
      pkgs.mesa.opencl
      pkgs.libvdpau-va-gl
    ];
  };



  environment.sessionVariables = {
    RADV_PERFTEST = "sam,video_decode,transfer_queue";
    AMD_VULKAN_ICD = "RADV";
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
    kernelModules = [ "amdgpu" ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  system.stateVersion = "24.05";
}
