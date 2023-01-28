{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.services.rclone-christoph = {
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "christoph";
    script = ''${pkgs.rclone}/bin/rclone --config ${config.age.secrets.rclone-conf.path} bisync snas:Dokumente ~/Dokumente'';
  };
  systemd.timers.rclone-christoph = {
    wantedBy = ["timers.target"];
    partOf = ["rclone-christoph.service"];
    timerConfig = {
      OnCalendar = "*:0/05";
      Unit = "rclone-christoph.service";
    };
  };
}
