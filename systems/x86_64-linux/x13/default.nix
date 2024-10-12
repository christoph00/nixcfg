{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "x13";

  internal.type = "laptop";
  internal.isV4 = true;
  internal.system.boot.secureBoot = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
      # pkgs.mesa.opencl
      intel-media-driver
      # pkgs.intel-compute-runtime

    ];
  };

  environment.systemPackages = [ pkgs.libva-utils pkgs.intel-gpu-tools ];


  environment.variables = {
    GST_VAAPI_ALL_DRIVERS = "1";
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.kernelParams = [
    "quiet"
    "pcie_port_pm=off"
    "i915.lvds_downclock=1"
    "i915.perf_stream_paranoid=0"
    "i915.semaphores=1"
    "i915.enable_fbc=1"
    "i915.enable_guc=3"
    "i915.enable_psr=2"
    "i915.fastboot=1"
    "i915.mitigations=off"
    "i915.modeset=1"
    "rcutree.rcu_idle_gp_delay=1"
    "splash"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
    "mem_sleep_default=deep"
    "ahci.mobile_lpm_policy=3"
    "mitigations=off"
  ];
  boot.initrd.kernelModules = [
    "i915"
  ];

  boot.kernelModules = [ "kvm-intel" "snd-seq" "snd-rawmidi" "snd-usb-audio" "btqca" "hci_qca" "hci_uart" ];

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';

  services.fstrim.enable = true;

  services.fwupd.enable = true;

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 4;
    criticalPowerAction = "Hibernate";
  };

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "24.05";
}
