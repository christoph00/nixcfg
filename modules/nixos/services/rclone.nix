{
  config,
  lib,
  flake,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret mkStrOpt;
  cfg = config.svc.rclone;
  rcloneOptions = [
    "nodev"
    "_netdev"
    "nofail"
    "allow_other"
    "dir-cache-time=2h"
    "uid=1000"
    "gid=1000"
    "umask=002"
    "vfs-cache-mode=full"
    "vfs-cache-max-size=10G"
    "vfs-fast-fingerprint"
    "vfs-write-back=1h"
    "vfs-cache-max-age=2h"
    "tpslimit=8"
    "tpslimit-burst=16"
    "drive-chunk-size=128M"
    "args2env"
    "config=${cfg.config}"
    "x-systemd.automount"
    "x-systemd.mount-timeout=5"
    "x-systemd.idle-timeout=30"
  ];
in
{
  options.svc.rclone = {
    enable = mkBoolOpt (!config.host.bootstrap);
    config = mkStrOpt config.age.secrets.rclone.path;

  };
  config = mkIf cfg.enable {

    age.secrets.rclone = mkSecret { file = "rclone"; };
    age.secrets.rclone-user = mkSecret {
      file = "rclone";
      owner = "christoph";
      group = "users";
    };

    environment.systemPackages = [ pkgs.rclone ];

    fileSystems."/media/box" = {
      device = "box:";
      fsType = "rclone";
      options = rcloneOptions;
    };
    fileSystems."/media/cloud" = {
      device = "cloud:";
      fsType = "rclone";
      options = rcloneOptions;
    };

    fileSystems."/media/nas" = {
      device = "nas:";
      fsType = "rclone";
      options = rcloneOptions;
    };

  };
}
