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

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      media = {
        rule = "Host(`graf.r505.de`)";
        tls = {certResolver = "cloudflare";};
        service = "grafana";
      };
    };
    services = {
      grafana = {
        loadBalancer = {
          servers = [{url = "http://localhost:2342";}];
        };
      };
    };
  };
}
