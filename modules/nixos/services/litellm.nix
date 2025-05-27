{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkSecret;
in
{
  config = mkIf config.services.litellm.enable {

    age.secrets.litellm = mkSecret { file = "litellm"; };

    sys.state.directories = [ "/var/lib/private/litellm" ];

    services.litellm = {
      environmentFile = config.age.secrets.litellm.path;
      port = 5059;
      host = config.network.netbird.ip;
    };

  };
}
