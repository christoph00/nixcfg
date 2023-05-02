{
  pkgs,
  config,
  lib,
  ...
}: {
  services.adguardhome = {
    enable = true;
    # openFirewall = true;
    settings.bind_port = 3000;
    settings.bind_host = "0.0.0.0";
  };

  environment.persistence."/nix/persist" = {
    directories = ["/var/lib/AdGuardHome"];
  };
}
