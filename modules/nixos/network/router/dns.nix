{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.network.router;
in
{
  config = mkIf cfg.enable {

    svc.dnscrypt = {
      enable = true;
      localDNS = "127.0.0.1:5353";
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        server = [
          "9.9.9.9"
          "8.8.8.8"
          "1.1.1.1"
          # "/ts.r505.de/100.100.100.100"
        ];
        port = 5353;
        domain-needed = true;
        bogus-priv = true;
        no-resolv = true;
        cache-size = 1000;

        local = "/lan/";
        domain = "lan";
        expand-hosts = true;

        address = "/ha.r505.de/192.168.2.2";
      };
    };
  };
}
