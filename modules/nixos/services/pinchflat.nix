{
  lib,
  flake,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkSecret;
in
{
  config = mkIf config.services.pinchflat.enable {
    sys.state.directories = [ config.services.pinchflat.mediaDir ];
    age.secrets.pinchflat = mkSecret { file = "pinchflat"; };
    services.pinchflat.secretsFile = config.age.secrets.pinchflat.path;

  };
}
