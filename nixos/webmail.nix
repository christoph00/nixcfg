{
  pkgs,
  config,
  ...
}: {
  services.alps = {
    enable = true;
    theme = "sourcehut";
    smtps.host = "mail.asche.co";
    imaps.host = "mail.asche.co";
  };
}
