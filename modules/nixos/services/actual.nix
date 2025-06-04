{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.actual.enable {
    sys.state.directories = [ "/var/lib/actual" ];
    services.actual = {
      settings = {
        port = 5088;
        hostname = config.network.netbird.ip;
      };
    };
  };
}
