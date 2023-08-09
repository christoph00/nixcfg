{pkgs, ...}: {
  nos = {
    type = "desktop";
    hw = {
      cpu = "intel";
      gpu = "amd";
      monitors = [
        {
          enabled = true;
          name = "DP-1";
          width = 3840;
          height = 2160;
          scale = 1.5;
        }
        {
          enabled = false;
          name = "DP-2";
          isPrimary = false;
        }
      ];
    };
    fs = {
      btrfs = true;
      persist = true;
      mainDisk = "/dev/nvme0n1p3";
      efiDisk = "/dev/nvme0n1p1";
    };
    enableHomeManager = true;

    network = {
      tweaks = true;
    };

    desktop = {
      enable = true;
      wm = "Hyprland";
      autologin = true;
      gaming = true;
    };
  };

  fileSystems = {
    "/media/Games" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@games" "noatime" "compress-force=zstd"];
    };

    "/media/ssd-data" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@data" "noatime" "compress-force=zstd"];
    };

    # "/media/hdd-data" = {
    #   device = "/dev/disk/by-uuid/25fc5836-72df-4881-8760-af49333fa485";
    #   fsType = "btrfs";
    #   options = ["subvol=@data" "noatime" "compress-force=zstd"];
    # };

    "/media/ncdata" = {
      device = "/dev/disk/by-label/ssd-data";
      options = ["subvol=@ncdata" "discard=async" "compress-force=zstd" "nofail"];
    };
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd = {
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    kernelModules = ["amdgpu"];
  };

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    package = pkgs.mesa_drivers;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  boot.kernelModules = ["kvm-intel" "acpi_call" "i2c_dev" "amdgpu"];
  boot.blacklistedKernelModules = ["dm_mod"];
  boot.kernelParams = [
    "quiet"
    "rcutree.rcu_idle_gp_delay=1"
    "splash"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
    "mem_sleep_default=deep"
    "amdgpu.gartsize=4096"
    "adgpu.ignore_crat=1"
  ];
}
