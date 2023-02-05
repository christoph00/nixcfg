{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.services.matcha = {
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "sftpgo";
    script = ''
      cd /media/data-ssd/christoph/Dokumente/Notes/Daily
      ${pkgs.matcha}/bin/matcha
    '';
  };
  systemd.timers.matcha = {
    wantedBy = ["timers.target"];
    partOf = ["matcha.service"];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "matcha.service";
    };
  };
}
