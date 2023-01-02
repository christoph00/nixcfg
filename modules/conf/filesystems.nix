{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.filesystems;
  hostname = config.networking.hostName;
  wipeScript = ''
    mkdir -p /btrfs
    mount -o subvol=/ /dev/disk/by-label/${hostname} /btrfs

    if [ -e "/btrfs/root/dontwipe" ]; then
      echo "Not wiping root"
    else
      echo "Cleaning subvolume"
      btrfs subvolume list -o /btrfs/@root | cut -f9 -d ' ' |
      while read subvolume; do
        btrfs subvolume delete "/btrfs/$subvolume"
      done && btrfs subvolume delete /btrfs/@root

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot /btrfs/@root-blank /btrfs/@root
    fi

    umount /btrfs
    rm -rf /btrfs
  '';
in {
  options.conf.filesystems.enable = mkEnableOption "btrfs filesystem";
  options.conf.filesystems.btrfs.home = mkOption {
    type = types.bool;
    default = false;
  };
  options.conf.filesystems.swap = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    #boot.initrd = mkIf config.conf.base.persist {
    #  supportedFilesystems = ["btrfs"];
    #  postDeviceCommands = mkBefore wipeScript;
    #};

    fileSystems = {
      #  "/" = {
      #    device = "/dev/disk/by-label/${hostname}";
      #    fsType = "btrfs";
      #    options = ["subvol=@root" "compress-force=zstd"];
      #  };

      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=2G" "mode=755"];
      };

      "/nix" = {
        device = "/dev/disk/by-label/${hostname}";
        fsType = "btrfs";
        options = ["subvol=@nix" "noatime" "compress-force=zstd"];
      };

      "/boot" = {
        device = "/dev/disk/by-label/UEFI";
        fsType = "vfat";
      };

      "/persist" = mkIf config.conf.base.persist {
        device = "/dev/disk/by-label/${hostname}";
        fsType = "btrfs";
        options = ["subvol=@persist" "noatime" "compress-force=zstd"];
        neededForBoot = true;
      };

      "/home" = mkIf cfg.btrfs.home {
        device = "/dev/disk/by-label/${hostname}";
        fsType = "btrfs";
        options = ["subvol=@home" "noatime" "compress-force=zstd"];
      };
    };
  };
}
