{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.system.fs;
  inherit (config.internal.system) state;
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
      "@root" = mkIf (!cfg.tmpRoot) {
        mountpoint = "/";
        mountOptions = [
          "compress-force=zstd:1"
          "noatime"
        ];
      };
      "@state" = {
        mountpoint = "/mnt/state";
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
          swapfile.size = cfg.swapSize;
        };
      };
    };
  };
in
{

  options.internal.system.fs = with types; {
    enable = mkBoolOpt' true;
    type = mkOption {
      type = enum [
        "btrfs"
        "bcachefs"
        "xfs"
      ];
      default = "btrfs";
    };

    device = mkStrOpt "/dev/nvme0n1" "Device to use for the root filesystem.";
    encrypted = mkBoolOpt config.internal.system.boot.encryptedRoot "Whether or not the root filesystem is encrypted.";
    tmpRoot = mkBoolOpt true "Whether or not the root filesystem is a tmpfs.";
    swap = mkBoolOpt true "Whether or not to use a swap partition.";
    swapSize = mkStrOpt "16G" "Swap size";
  };

  config = mkIf cfg.enable (

    mkMerge [
      {
        boot.supportedFilesystems.zfs = lib.mkForce false;
        disko.devices = {
          nodev."/" = mkIf cfg.tmpRoot {
            fsType = "tmpfs";
            mountOptions = [
              "size=95%"
              "defaults"
              # set mode to 755, otherwise systemd will set it to 777, which cause problems.
              # relatime: Update inode access times relative to modify or change time.
              "mode=755"
            ];
          };
          disk.main.type = "disk";
          #disk.main.imageSize = "12G";
          disk.main.device = cfg.device; # The device to partition
        };

      }

      (mkIf (cfg.encrypted) {
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

      (mkIf (!cfg.encrypted && cfg.type == "btrfs") {
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

      (mkIf (cfg.type == "xfs" && state.enable) {

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
      (mkIf (cfg.type == "xfs" && !state.enable) {
        disko.devices.disk.main.content = {
          type = "gpt";
          partitions = {
            inherit ESP;
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };

      })

    ]
  );
}
