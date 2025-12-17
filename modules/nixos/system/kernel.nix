{
  flake,
  lib,
  config,
  options,
  perSystem,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce mkDefault;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.sys.kernel;
in {
  options.sys.kernel = {
    enable = mkBoolOpt true;
  };
  config = mkIf cfg.enable {
    services.scx.enable = config.host.graphical;
    services.scx.scheduler = "scx_bpfland";
    systemd.services.scx.serviceConfig.LogNamespace = "sched-ext";

    boot = {
      kernelPackages =
        # if config.host.graphical then
        #   perSystem.chaotic.linuxPackages_cachyos-lto
        # else if config.host.server then
        #   perSystem.chaotic.linuxPackages_cachyos-server
        # else
        mkDefault pkgs.linuxPackages_latest;
      supportedFilesystems = mkForce [
        "btrfs"
        "vfat"
        "f2fs"
        "xfs"
        "ext4"
        "vfat"
      ];
      blacklistedKernelModules = [
        # Novideo
        "nvidia"
        "nvidia-drm"
        "nvidia-modeset"
        "nouveau"

        # Obscure network protocols
        "ax25"
        "netrom"
        "rose"

        # Old or rare or insufficiently audited filesystems
        "adfs"
        "affs"
        "bfs"
        "befs"
        "cramfs"
        "efs"
        "erofs"
        "exofs"
        "freevxfs"
        "vivid"
        "gfs2"
        "ksmbd"
        "nfsv4"
        "nfsv3"
        "cifs"
        "nfs"
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "btusb"
        "hpfs"
        "jfs"
        "minix"
        "nilfs2"
        "omfs"
        "qnx4"
        "qnx6"
        "sysv"
      ];
    };
  };
}
