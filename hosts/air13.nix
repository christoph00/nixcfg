{
  pkgs,
  config,
  lib,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["i915"];
    };
  };


  boot.kernelModules = ["kvm-intel" "acpi_call" "bbswitch" "iwlwifi"];
  boot.blacklistedKernelModules = ["nouveau"];
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
  ];
  boot.resumeDevice = "/dev/nvme0n1p2";
  boot.extraModprobeConfig = ''
    options bbswitch load_state=-1 unload_state=1
    options cfg80211 ieee80211_regdom="DE"
  '';

  services.fstrim.enable = lib.mkDefault true;

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=2G" "mode=755"];
    };

    "/nix" = {
      device = "/dev/disk/by-label/air13";
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress-force=zstd"];
    };

    "/boot" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };

    "/persist" = {
      device = "/dev/disk/by-label/air13";
      fsType = "btrfs";
      options = ["subvol=@persist" "noatime" "compress-force=zstd"];
      neededForBoot = true;
    };

    "/home" = {
      device = "/dev/disk/by-label/air13";
      fsType = "btrfs";
      options = ["subvol=@home" "noatime" "compress-force=zstd"];
    };
  };

  hardware.nvidia.modesetting.enable = false;

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "air13";

  services.xserver.videoDrivers = ["intel"];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
