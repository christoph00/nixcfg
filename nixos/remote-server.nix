{
  pkgs,
  config,
  lib,
  ...
}: {
  services.grafana = {
    enable = true;
    domain = "graf.r505.de";
    port = 2342;
    addr = "127.0.0.1";
  };
}
