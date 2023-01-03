{
  pkgs,
  config,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["i915"];
      #      systemd.enable = true;
    };
    # make modules available to modprobe
    extraModulePackages = with config.boot.kernelPackages; [acpi_call];

    # use latest kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

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

  conf = {
    base.enable = true;
    cli.enable = true;
    cli.helix.enable = true;
    theme.enable = true;
    applications.enable = true;
    applications.wezterm.enable = true;
    profile.laptop = true;
    filesystems.enable = true;
    filesystems.swap = true;
    boot.enable = true;
    users.enable = true;
    users.user = "christoph";
    users.home-manager = true;
    network.enable = true;
    network.wireless = true;
    #network.tailscale.enable = true;

    fonts.enable = true;
    desktop = {
      enable = true;
      # window-manager = "hyprland";
      # login-manager = "greetd";
      gaming = false;
    };
  };
}
