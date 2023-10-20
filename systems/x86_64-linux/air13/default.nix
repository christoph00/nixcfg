{
  pkgs,
  config,
  lib,
  channel,
  inputs,
  ...
}:
with lib;
with lib.chr; {


  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];

  boot.kernelModules = ["kvm-intel" "acpi_call" "bbswitch" "iwlwifi" "i915"];
  boot.blacklistedKernelModules = ["nouveau" "nvidia"];
  boot.kernelParams = [
    "quiet"
    "pcie_port_pm=off"
    "i915.i915_enable_rc6=1"
    "i915.i915_enable_fbc=1"
    "i915.enable_psr=2"
    "i915.lvds_downclock=1"
    "i915.perf_stream_paranoid=0"
    "i915.semaphores=1"
    "rcutree.rcu_idle_gp_delay=1"
    "splash"
    "i915.fastboot=1"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
    "mem_sleep_default=deep"
    "ahci.mobile_lpm_policy=3"
    "resume_offset=15024568"
    "resume=UUID=b7759054-0eab-42fe-bad0-4f1d92694c9f"
  ];
  boot.extraModprobeConfig = ''
    options bbswitch load_state=-1 unload_state=1
    options cfg80211 ieee80211_regdom="DE"
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    options iwlwifi power_save=Y
  '';

  #boot.resumeDevice = "/dev/disk/by-label/air13";

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  chr = {
    type = "laptop";
  };
  chr.system.filesystem = {
    enable = true;
    btrfs = true;
    disko = true;
    persist = true;
    mainDisk = "/dev/nvme0n1";
    rootOnTmpfs = true;
  };

  system.stateVersion = "23.11";
}
