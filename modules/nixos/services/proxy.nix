{
  config,
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;

in
{
  options.svc.proxy.enable = mkBoolOpt false;
  config = mkIf config.svc.proxy.enable {

    services.tinyproxy = {
      enable = true;
      settings = {
        Port = 8888;
        Listen = config.network.netbird.ip;
      };

    };

  };

}
