{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.services.mount-media-nd = {
    description = "Mount christoph/NAS";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      #User = "christoph";
      Type = "notify";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p /media/ND";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config ${config.age.secrets.rclone-nd-conf.path} --vfs-cache-mode full --allow-other --vfs-cache-max-size 100M --no-modtime --gid 100 --uid 1000 --umask 022 ND:data /media/ND";
      ExecStop = "/bin/fusermount -u /media/ND";
      Restart = "always";
      RestartSec = "20";
    };
  };
}
