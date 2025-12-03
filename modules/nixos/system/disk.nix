{
  lib,
  config,
  flake,
  inputs,
  ...
}:

with builtins;
with lib;
with flake.lib;

let
  cfg = config.sys;
  ESP = {
    size = "800M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "defaults" ];
    };
  };

  rollback = ''
    mkdir /btrfs
    mount -t btrfs /dev/mapper/cryptroot /mnt

    echo "Cleaning subvolume"
            btrfs subvolume list -o /mnt/@root | cut -f9 -d ' ' |
            while read subvolume; do
              btrfs subvolume delete "/mnt/$subvolume"
            done && btrfs subvolume delete /mnt/@root

            echo "Restoring blank subvolume"
            btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

            umount /mnt
  '';

  btrfsLayout = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    subvolumes = {
      "@root" = mkIf (!cfg.disk.tmpRoot) {
        mountpoint = "/";
        mountOptions = [
          "compress-force=zstd:1"
          "noatime"
        ];
      };
      "@state" = mkIf cfg.state.enable {
        mountpoint = "${cfg.state.stateDir}";
        mountOptions = [
          "compress-force=zstd:1"
          "noatime"
        ];
      };
      "@home" = {
        mountpoint = "/home";
        mountOptions = [
          "compress-force=zstd:1"
          "noatime"
        ];
      };
      "@nix" = {
        mountOptions = [
          "compress-force=zstd:1"
          "noatime"
        ];
        mountpoint = "/nix";
      };
      "@swap" = {
        mountpoint = "/.swapvol";
        swap = {
          swapfile.size = cfg.disk.swapSize;
        };
      };
    };
  };
in
{

  imports = [
    inputs.disko.nixosModules.disko
  ];

  options.sys.disk = with types; {
    enable = mkBoolOpt true;
    type = mkOption {
      type = enum [
        "btrfs"
        "xfs"
        "ext4"
      ];
      default = "btrfs";
    };

    device = mkStrOpt "/dev/sda";
    encrypted = mkBoolOpt false;
    tmpRoot = mkBoolOpt cfg.state.enable;
    swap = mkBoolOpt true;
    swapSize = mkStrOpt "1G";
    rollback = mkBoolOpt true;
    forceDevice = mkBoolOpt false;

  };

  config = mkIf cfg.disk.enable (

    mkMerge [
      {

        boot.supportedFilesystems.zfs = lib.mkForce false;

        disko.devices = {
          nodev."/" = mkIf cfg.disk.tmpRoot {
            fsType = "tmpfs";
            mountOptions = [
              "size=95%"
              "defaults"
              "mode=755"
            ];
          };
          disk.main.type = "disk";
          disk.main.imageSize = "12G";
          disk.main.device = cfg.disk.device; # The device to partition
        };

        zramSwap = {
          enable = true;
          memoryPercent = 150;
        };

        boot.kernel.sysctl = mkIf config.zramSwap.enable {
          "vm.swappiness" = 180;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
          "vm.page-cluster" = 0;
        };

        boot.initrd.systemd.services.rollback =
          mkIf (cfg.disk.rollback && !cfg.disk.tmpRoot && cfg.disk.type == "btrfs")
            {
              description = "Rollback BTRFS root subvolume to a pristine state";
              wantedBy = [ "initrd.target" ];
              before = [ "sysroot.mount" ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = rollback;
            };

        services.fstrim = mkIf (!config.host.vm) {
          enable = true;
          interval = "weekly";
        };

        services.smartd.enable = !config.host.vm;

        services.btrfs.autoScrub = mkIf (cfg.disk.type == "btrfs") {
          enable = true;
          interval = "weekly";
          fileSystems = [
            "/nix"
            "/home"
            "/mnt/state"
          ];
        };

      }

      (mkIf (cfg.disk.encrypted && cfg.disk.type == "btrfs") {
        disko.devices.disk.main.content = {
          type = "gpt";
          partitions = {
            inherit ESP;
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                # echo -n "<password" > /tmp/secret.key
                passwordFile = "/tmp/secret.key";

                content = btrfsLayout;
              };
            };
          };
        };
      })

      (mkIf (!cfg.disk.encrypted && cfg.disk.type == "btrfs") {
        disko.devices.disk.main.content = {
          type = "gpt";
          partitions = {
            inherit ESP;
            root = {
              size = "100%";
              content = btrfsLayout;
            };
          };
        };
      })

      ## TODO: xfs/ext4 with state
      (mkIf ((cfg.disk.type == "xfs" || cfg.disk.type == "ext4") && cfg.state.enable) {

        disko.devices.nodev = {
          "/home" = {
            fsType = "auto";
            preMountHook = "mkdir -p /mnt/state/home";
            device = "/mnt/state/home";
            mountOptions = [
              "bind"
              "noatime"
            ];
          };
          "/nix" = {
            fsType = "auto";
            preMountHook = "mkdir -p /mnt/state/nix";
            device = "/mnt/state/nix";
            mountOptions = [
              "bind"
              "noatime"
            ];
          };
        };
      })

      (mkIf ((cfg.disk.type == "xfs" || cfg.disk.type == "ext4") && !cfg.state.enable) {

        disko.devices.disk.main.content = {
          type = "gpt";
          partitions = {
            inherit ESP;
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "${cfg.disk.type}";
                mountpoint = "/";
              };
            };
          };
        };

        fileSystems = mkIf cfg.disk.forceDevice {
          "/".device = lib.mkForce "${cfg.disk.device}2";
          "/boot".device = lib.mkForce "${cfg.disk.device}1";
        };

        boot.tmp = {
          cleanOnBoot = true;
        };

      })

      (mkIf cfg.disk.encrypted {
        boot = {
          initrd.availableKernelModules = [
            "aesni_intel"
            "cryptd"
            "usb_storage"
          ];

          kernelParams = [
            "luks.options=timeout=0"
            "rd.luks.options=timeout=0"
            "rootflags=x-systemd.device-timeout=0"
          ];
        };
      })

    ]
  );
}
