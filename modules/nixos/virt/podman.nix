{
  lib,
  config,
  pkgs,
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

    users.users.christoph.extraGroups = [
      "podman"
    ];

    environment.systemPackages = [
      pkgs.podman
    ];

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
    };
  };
}
