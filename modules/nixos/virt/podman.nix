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

    virtualisation.quadlet.networks.main.networkConfig = {
      name = "main";
      ipv6 = true;
      internal = true;
      interfaceName = "podman1";
    };

    networking.firewall.trustedInterfaces = [ "podman1" ];

    virtualisation.podman = {
      enable = true;
    };
  };
  options.virtualisation.quadlet.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { ... }:
        {
          containerConfig.networks = lib.mkDefault [ config.virtualisation.quadlet.networks.main ];
        }
      )
    );
  };
}
