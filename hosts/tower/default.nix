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

  hardware.steam-hardware.enable = true;

  services.fstrim.enable = lib.mkDefault true;

  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    disk.main = {
      device = "/dev/sda"; #FIXME
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "128MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nixos";
            type = "partition";
            start = "128MiB";
            end = "100%";
            content = {
              type = "btrfs";
              extraArgs = "-f"; # Override existing partition
              subvolumes = {
                # "@root" = {
                #   mountpoint = "/";
                # };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
              };
            };
          }
        ];
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };
    };
  };

  # fileSystems = {
  #   "/" = {
  #     device = "none";
  #     fsType = "tmpfs";
  #     options = ["defaults" "size=2G" "mode=755"];
  #   };

  #   "/nix" = {
  #     device = "/dev/disk/by-label/tower";
  #     fsType = "btrfs";
  #     options = ["subvol=@nix" "noatime" "compress-force=zstd"];
  #   };

  #   "/boot" = {
  #     device = "/dev/disk/by-label/UEFI";
  #     fsType = "vfat";
  #   };

  #   "/persist" = {
  #     device = "/dev/disk/by-label/tower";
  #     fsType = "btrfs";
  #     options = ["subvol=@persist" "noatime" "compress-force=zstd"];
  #     neededForBoot = true;
  #   };

  #   # "/home" = {
  #   #   device = "/dev/disk/by-label/tower";
  #   #   fsType = "btrfs";
  #   #   options = ["subvol=@home" "noatime" "compress-force=zstd"];
  #   # };
  # };

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "powersave";

  networking.hostName = "tower";

  services.xserver.videoDrivers = ["amdgpu"];
}
