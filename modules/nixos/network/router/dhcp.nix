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
      };
    };
  };
}
