{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.virt;

in
{
  config = mkIf cfg.podman {
    sys.state.directories = [
      "/var/lib/containers"
    ];
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
