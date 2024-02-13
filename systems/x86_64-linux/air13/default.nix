{
  pkgs,
  config,
  lib,
  channel,
  inputs,
  system,
  modulesPath,
  ...
}:
with lib;
with lib.chr; let
  inherit (inputs) nixos-hardware;
in {
  imports = with nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    common-cpu-intel
    common-pc
    common-pc-ssd
  ];
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];

  boot.kernelModules = ["kvm-intel" "acpi_call"];
  boot.blacklistedKernelModules = ["nouveau" "iwlwifi" "snd_hda_intel"];
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
  ];
  #boot.resumeDevice = "/dev/disk/by-label/air13";

  # services.udev.extraRules = ''
  #   # Remove NVIDIA USB xHCI Host Controller devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA USB Type-C UCSI devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA Audio devices, if present
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

  #   # Remove NVIDIA VGA/3D controller devices
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  # '';

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  chr = {
    type = "server";
    services = {
      #   smart-home = true;
      #   home-assistant.hostname = "home.r505.de";
      #ollama.enable = true;
      vmetrics.enable = true;
      monitoring.scrapeExtra = true;
      zwave.enable = true;
    };
    vms = {
      enable = true;
      smarthome.enable = true;
    };
  };
  chr.system.filesystem = {
    enable = true;
    btrfs = true;
    persist = true;
    mainDisk = "/dev/nvme0n1p3";
    efiDisk = "/dev/nvme0n1p1";
    rootOnTmpfs = true;
  };

  services.logind.lidSwitch = "ignore";
  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    nvidiaPersistenced = true;
  };
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  virtualisation.podman.enableNvidia = true;
  services.xserver.videoDrivers = ["nvidia"];

  services.upower = {
    enable = true;
    timeLow = 1200;
    timeCritical = 300;
    timeAction = 120;
    percentageLow = 10;
    percentageCritical = 3;
    percentageAction = 2;
    ignoreLid = false;
    noPollBatteries = false;
    criticalPowerAction = "PowerOff";
    usePercentageForPolicy = true;
    enableWattsUpPro = false;
  };
  services.thermald.enable = true;

  networking.useNetworkd = true;
  systemd.network.networks."40-wired" = {
    matchConfig = {Name = lib.mkForce "enp* eth*";};
    DHCP = "yes";
    networkConfig = {
      IPv6PrivacyExtensions = "yes";
    };
  };

  system.stateVersion = "23.11";
}
