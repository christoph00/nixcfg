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
    services.resolved.extraConfig = ''
      DNSStubListener=false
    '';
    services.resolved.fallbackDns = [ "127.0.0.1" ];

    networking = {

      nameservers = [
        "::1"
        "127.0.0.1"
      ];
    };

  };
}
