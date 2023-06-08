{
  pkgs,
  config,
  lib,
  ...
}: {
  # systemd.services.rclone-christoph = {
  #   serviceConfig.Type = "oneshot";
  #   serviceConfig.User = "christoph";
  #   script = ''${pkgs.rclone}/bin/rclone --config ${config.age.secrets.rclone-conf.path} bisync snas:Dokumente ~/Dokumente'';
  # };
  # systemd.timers.rclone-christoph = {
  #   wantedBy = ["timers.target"];
  #   partOf = ["rclone-christoph.service"];
  #   timerConfig = {
  #     OnCalendar = "*:0/05";
  #     Unit = "rclone-christoph.service";
  #   };
  # };

  # systemd.services.mount-christoph-nas = {
  #   description = "Mount christoph/NAS";
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     #User = "christoph";
  #     Type = "notify";
  #     ExecStartPre = "/run/current-system/sw/bin/mkdir -p /home/christoph/NAS";
  #     ExecStart = "${pkgs.rclone}/bin/rclone mount --config ${config.age.secrets.rclone-conf.path} --vfs-cache-mode full --allow-other --vfs-cache-max-size 100M --no-modtime --gid 100 --uid 1000 --umask 022 CSNAS: /home/christoph/NAS";
  #     ExecStop = "/bin/fusermount -u /home/christoph/NAS";
  #     Restart = "always";
  #     RestartSec = "20";
  #     Environment = [
  #       "PATH=/run/wrappers/bin/:$PATH"
  #     ];
  #   };
  # };
}
