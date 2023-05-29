{
  pkgs,
  config,
  lib,
  ...
}: {
  # services.grafana = {
  #   enable = true;
  #   domain = "graf.r505.de";
  #   port = 2342;
  #   addr = "0.0.0.0";
  # };
  services.caddy.enable = true;
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/grafana";
        user = "grafana";
        group = "grafana";
      }
    ];
  };
}
