{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.network.router;
in
{
  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      settings = {
        bind-dynamic = true;
        interface = [ "lan" ];
        dhcp-range = [ "192.168.2.21,192.168.2.249,255.255.255.0,24h" ];
        server = [
          "9.9.9.9"
          "8.8.8.8"
          "1.1.1.1"
          # "/ts.r505.de/100.100.100.100"
        ];
        port = 53;
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
