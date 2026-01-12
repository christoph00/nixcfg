{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkSecret;
in
{
  config = mkIf config.services.beszel.agent.enable {
    sys.state.directories = [ "/var/lib/beszel-agent" ];
     age.secrets.beszel-env = mkSecret {
      file = "beszel-env";
    };
    services.beszel.agent = {
      environmentFile = config.age.secrets."beszel-env".file;
    };
  };
}
