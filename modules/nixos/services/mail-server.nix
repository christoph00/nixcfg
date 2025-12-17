{
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
in
{
  config = mkIf config.services.stalwart-mail.enable {
    sys.state.directories = [ "/var/lib/stalart-mail" ];

    services.stalwart-mail = {
      openFirewall = true;
    };

  };
}
