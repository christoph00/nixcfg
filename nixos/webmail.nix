{
  pkgs,
  config,
  lib,
  ...
}: {
  services.alps = {
    enable = true;
  };

  systemd.services.alps.serviceConfig.ExecStart = lib.mkForce "${pkgs.alps}/bin/alps -addr 0.0.0.0:8077 -theme sourcehut imaps://mail.asche.co:993 smtps://mail.asche.co:465 https://cal.r505.de/dav.php";
}
