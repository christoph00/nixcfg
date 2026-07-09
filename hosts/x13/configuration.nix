{
  flake,
  pkgs,
  config,
  ...
}: {
  imports = [flake.modules.nixos.host];
  facter.reportPath = ./facter.json;
  networking.hostName = "x13";
  hw.cpu = "intel";
  hw.gpu = "intel";
  hw.ram = 16;
  host.graphical = true;
  sys.boot.secureBoot = false;
  sys.disk.device = "/dev/nvme0n1";
  sys.disk.encrypted = true;

  age.secrets.x13-root-key = flake.lib.mkSecret {file = "x13-root-key";};
  boot.initrd.secrets."/root.key" = config.age.secrets.x13-root-key.path;
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    keyFile = "/root.key";
    keyFileTimeout = 10;
    allowDiscards = true;
    # fallbackToPassword = true;
  };

  desktop.enable = true;
  host.gaming = true;
  desktop.gaming.enable = true;
  network.enableWifi = true;

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
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelParams = [
      # --- quiet / fast boot ---
      "quiet"
      "splash"
      "loglevel=3"
      "udev.log-priority=3"
      "vt.global_cursor_default=0"
      # --- i915 (CometLake-U GT2 / UHD Graphics) ---
      # Only keep safe, non-tainting options. The previously set
      # enable_fbc / enable_guc / enable_psr / mitigations params each
      # printed "Setting dangerous option ... - tainting kernel" on boot.
      #   - enable_fbc is the default anyway,
      #   - enable_guc is irrelevant for Gen11 (no GuC submission used),
      #   - enable_psr=2 (PSR2) is a frequent source of flicker on these
      #     eDP panels,
      #   - mitigations=off disables Spectre/Meltdown mitigations (security).
      # lvds_downclock was a no-op: this panel is eDP, there is no LVDS.
      "i915.modeset=1"
      "i915.fastboot=1"
      "i915.semaphores=1"
      "i915.perf_stream_paranoid=0" # allow intel-gpu-tools / GPU metrics
      # --- power / sleep ---
      "mem_sleep_default=deep"
      "rcutree.rcu_idle_gp_delay=1"
      # --- Thunderbolt 3 (Alpine Ridge JHL6240) stability on Comet Lake ---
      # Note: FADT already disables PCIe ASPM on this machine, so this mainly
      # keeps PCIe port runtime PM off. Remove if you want to test battery life.
      "pcie_port_pm=off"
    ];
    initrd.kernelModules = ["i915"];

    kernelModules = [
      "kvm-intel"
      "snd-seq"
      "snd-rawmidi"
      "snd-usb-audio"
      # NOTE: hci_uart / btqca / hci_qca removed. They are for Qualcomm QCA
      # Bluetooth over UART. This ThinkPad has an Intel AX201 attached via USB
      # (8087:0026), which is driven by btusb. btusb was wrongly blacklisted
      # in modules/nixos/system/kernel.nix (listed under "filesystems") and is
      # now un-blacklisted there.
    ];

    extraModprobeConfig = ''
      # Comet Lake ALC257 works fine with the legacy HDA driver
      # (snd_hda_intel + snd_hda_codec_alc269) -> card1 "PCH". The previous
      # dsp_driver=1 forced the SOF stack to load ~10 modules that never
      # registered a sound card. Dropped, so SOF is no longer pulled in.
      options thinkpad_acpi fan_control=1 experimental=1
      # WiFi power management for the AX201 (battery)
      options iwlwifi power_save=1
    '';
  };

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

  services.power-profiles-daemon.enable = true;

  # Intel thermal/clamping management for Comet Lake-U. Coexists with
  # power-profiles-daemon (PPD handles profiles, thermald handles passive
  # thermal throttling). Drop it if you ever observe fan/thermal conflicts.
  services.thermald.enable = true;

  # Thunderbolt 3 (Alpine Ridge) device approval / management.
  services.hardware.bolt.enable = true;

  # Yoga convertible: accelerometer + gyro are exposed as iio devices.
  # iio-sensor-proxy enables automatic screen rotation and proper tablet-mode
  # handling under GNOME/KDE.
  hardware.sensor.iio.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
}
