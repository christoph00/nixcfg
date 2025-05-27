{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  inherit (flake.lib) mkSecret mkBoolOpt;
  user = "litellm";
in
{
  options.svc.litellm.enable = mkBoolOpt false;
  config = mkIf config.svc.litellm.enable {

    age.secrets."litellm.yaml" = mkSecret {
      file = "litellm-conf";
    };

    # sys.state.directories = [ "/var/lib/litellm" ];

    virtualisation.quadlet.autoEscape = true;
    virtualisation.quadlet.containers.litellm = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        # renovate: docker-image
        image = "ghcr.io/berriai/litellm-database:main-latest";
        autoUpdate = "registry";
        userns = "keep-id";
        publishPorts = [ "4000:4000" ];

        # environmentHost = true;

        # podmanArgs = [ ];
        volumes = [ "${config.age.secrets."litellm.yaml".path}:/app/config.yaml:ro" ];
      };
    };
  };
}
