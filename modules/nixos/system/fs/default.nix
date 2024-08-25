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

      (mkIf (cfg.type == "xfs") {
        disko.devices.disk.main.content = {
          type = "gpt";
          partitions = {
            # The EFI & Boot partition
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
            state = {
              name = "state";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/state";
              };
            };
          };
        };

        fileSystems = {
          "/mnt/state" = {
            neededForBoot = true;
          };

        };

      })

      (mkIf (config.internal.system.state.enable) {
        disko.devices = {
          nodev."/home" = {
            fsType = "auto";
            device = "/mnt/state/home";
            mountOptions = [ "bind" ];
          };
          nodev."/nix" = {
            fsType = "auto";
            device = "/mnt/state/nix";
            mountOptions = [
              "bind"
              "noatime"
            ];
          };
        };
      })

    ]
  );
}
