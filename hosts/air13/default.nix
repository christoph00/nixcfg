{
  pkgs,
  config,
  lib,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    };
  };

  boot.kernelModules = ["kvm-intel" "acpi_call" "bbswitch" "iwlwifi" "i915"];
  # boot.blacklistedKernelModules = ["nouveau"];
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
    "resume_offset=20260096"
  ];
  boot.extraModprobeConfig = ''
    options bbswitch load_state=-1 unload_state=1
    options cfg80211 ieee80211_regdom="DE"
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    options iwlwifi power_save=Y
    blacklist nouveau
    options nouveau modeset=0
  '';

  boot.resumeDevice = "/dev/disk/by-label/air13";

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
  boot.blacklistedKernelModules = ["nouveau" "nvidia"];

  services.fstrim.enable = true;

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=2G" "mode=755"];
    };

    # "/home/christoph" = {
    #   device = "none";
    #   fsType = "tmpfs"; # Can be stored on normal drive or on tmpfs as well
    #   options = ["size=2G" "mode=777"];
    # };

    "/nix" = {
      device = "/dev/disk/by-label/air13";
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress-force=zstd"];
    };

    "/boot" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };

    "/nix/persist" = {
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

    "/swap" = {
      device = "/dev/disk/by-label/air13";
      fsType = "btrfs";
      options = ["subvol=@swap" "noatime"];
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8196;
    }
  ];

  # hardware.nvidia.modesetting.enable = false;

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "powersave";
  services.thermald.enable = true;

  networking.hostName = "air13";

  services.xserver.videoDrivers = ["intel"];

  #nixpkgs.config.packageOverrides = pkgs: {
  #  vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  #};
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [intel-media-driver vaapiIntel];
  };

  # Secrets
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.rclone-conf = {
    file = ../../secrets/rclone.conf;
    path = "/home/christoph/.config/rclone/rclone.conf";
    owner = "christoph";
    mode = "660";
  };
}
