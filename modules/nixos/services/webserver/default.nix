{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.services.webserver;
in
{
  options.chr.services.webserver = with types; {
    enable = mkBoolOpt false "Enable Webserver";
  };
  config = lib.mkIf cfg.enable {
    services.nginx.enable = mkForce false;

    services.caddy = {
      enable = true;
      package = pkgs.caddy-cloudflare;
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets.caddy-env.file = ../../../../secrets/caddy.env;

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = config.age.secrets.caddy-env.path;
        TimeoutStartSec = "5m";
      };
    };
  };
}
