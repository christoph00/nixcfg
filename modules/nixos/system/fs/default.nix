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
  state = config.internal.system.state;
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

  btrfsLayout = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    subvolumes = {
      "@state" = {
        mountpoint = "/mnt/state";
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
          swapfile.size = "16G";
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
      default = "xfs";
    };
    device = mkStrOpt "/dev/nvme0n1" "Device to use for the root filesystem.";
    encrypted = mkBoolOpt config.internal.system.boot.encryptedRoot "Whether or not the root filesystem is encrypted.";
    tmpRoot = mkBoolOpt config.internal.system.state.enable "Whether or not the root filesystem is a tmpfs.";
    swap = mkBoolOpt true "Whether or not to use a swap partition.";
  };

  config = (
    mkMerge [
      {
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
                settings = {
                  allowDiscards = true;
                  # echo -n "<password" > /tmp/secret.key
                  passwordFile = "/tmp/secret.key";
                };
                content = {
                  type = "filesystem";
                  format = cfg.type;
                  mountpoint = mkIf (cfg.type == "xfs" && state.enable) "/mnt/state";
                };
              };
            };
          };
        };
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
