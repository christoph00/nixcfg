{
  pkgs,
  config,
  lib,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["amdgpu"];
    };
  };
  boot.kernelModules = ["kvm-intel" "acpi_call"];
  boot.blacklistedKernelModules = ["dm_mod"];
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

  #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  #boot.zfs.extraPools = ["zdata"];

  networking.hostId = "007f0200";

  hardware.steam-hardware.enable = true;

  services.fstrim.enable = lib.mkDefault true;

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=2G" "mode=755"];
    };

    "/nix" = {
      device = "/dev/disk/by-label/tower";
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress-force=zstd"];
    };

    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };

    "/nix/persist" = {
      device = "/dev/disk/by-label/tower";
      fsType = "btrfs";
      options = ["subvol=@persist" "noatime" "compress-force=zstd"];
      neededForBoot = true;
    };
    "/nix/persist/games" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@games" "noatime" "compress-force=zstd"];
    };

    "/media/ssd-data" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = ["subvol=@data" "noatime" "compress-force=zstd"];
    };
    # "/home" = {
    #   device = "/dev/disk/by-label/tower";
    #   fsType = "btrfs";
    #   options = ["subvol=@home" "noatime" "compress-force=zstd"];
    # };

    "/media/hdd-data" = {
      device = "/dev/disk/by-uuid/25fc5836-72df-4881-8760-af49333fa485";
      fsType = "btrfs";
      options = ["subvol=@data" "noatime" "compress-force=zstd"];
    };
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "tower";

  services.xserver.videoDrivers = ["amdgpu"];

  # Secrets
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.wayvnc-key = {
    file = ../../secrets/wayvnc-key;
    path = "/etc/wayvnc/key.pem";
    owner = "christoph";
    mode = "660";
  };
  age.secrets.wayvnc-cert = {
    file = ../../secrets/wayvnc-cert;
    path = "/etc/wayvnc/cert.pem";
    owner = "christoph";
    mode = "660";
  };
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
