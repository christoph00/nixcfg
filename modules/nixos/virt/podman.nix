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

    networking.firewall.trustedInterfaces = [ "podman0" ];

    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
        subnets = [
          {
            subnet = "10.88.0.0/16";
            gateway = "10.88.0.1";
          }
          {
            subnet = "fd00::/80";
            gateway = "fd00::1";
          }
        ];
      };
    };
  };
}
