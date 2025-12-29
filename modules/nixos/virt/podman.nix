{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.virt;

in
{
  imports = [ inputs.quadlet-nix.nixosModules.quadlet ];
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

    virtualisation.quadlet.enable = true;

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
