{
  config,
  lib,
  flake,
  options,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret mkStrOpt;
  cfg = config.svc.rclone;
  rcloneOptions = [
    "nodev"
    "nofail"
    "allow_other"
    # "dir-cache-time=2h"
    "uid=1000"
    "gid=1101"
    "umask=002"
    "vfs-cache-mode=full"
    "vfs-cache-max-size=8G"
    "vfs-fast-fingerprint"
    # "vfs-write-back=1h"
    # "vfs-cache-max-age=2h"
    # "tpslimit=8"
    # "tpslimit-burst=16"
    # "drive-chunk-size=128M"
    "args2env"
    "config=${cfg.config}"
    "cache-dir=/var/cache/rclone"
    "x-systemd.automount"
    "x-systemd.mount-timeout=5"
    "x-systemd.idle-timeout=30"
    "x-gvfs-hide"
  ];

  # wrapped = inputs.wrapper-manager.lib {
  #   inherit pkgs;
  #   modules = [
  #     {
  #       wrappers = {
  #         rclone = {
  #           renames.rclone = "rcloneu";
  #           renames."mount.rclone" = "mount.rcloneu";
  #           basePackage = pkgs.rclone;
  #           prependFlags = [
  #             "--config"
  #             "${config.age.secrets.rclone-user.path}"
  #           ];
  #         };
  #       };
  #     }
  #   ];
  # };
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

    environment.systemPackages = [
      pkgs.rclone
    ];
    # ] ++ (builtins.attrValues wrapped.config.build.packages);

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
