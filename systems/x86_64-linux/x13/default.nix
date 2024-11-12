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

  facter.reportPath = ./facter.json;

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

  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.intel-gpu-tools
  ];

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

  boot.kernelModules = [
    "kvm-intel"
    "snd-seq"
    "snd-rawmidi"
    "snd-usb-audio"
    "btqca"
    "hci_qca"
    "hci_uart"
  ];

  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
    options thinkpad_acpi fan_control=1 experimental=1
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

  services.thinkfan.enable = true;

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      WIFI_PWR_ON_AC = "on";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      CPU_MIN_PERF_ON_AC = 10;
      CPU_MAX_PERF_ON_AC = 90;
      CPU_MIN_PERF_ON_BAT = 10;
      CPU_MAX_PERF_ON_BAT = 50;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      MEM_SLEEP_ON_AC = "deep";
      MEM_SLEEP_ON_BAT = "deep";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      RADEON_POWER_PROFILE_ON_AC = "high";
      RADEON_POWER_PROFILE_ON_BAT = "low";

      INTEL_GPU_MIN_FREQ_ON_AC = 600;
      INTEL_GPU_MIN_FREQ_ON_BAT = 600;
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "24.05";
}
