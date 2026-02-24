{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib)
    btrfsVolume
    mountVolume
    mkBoolOpt
    mkSecret
    ;
in
{
  options.cnt.stalwart = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.stalwart.enable {
    virt.podman = true;
    age.secrets."stalwart-env" = mkSecret {
      file = "stalwart-env";
    };

    networking.firewall.allowedTCPPorts = [
      25
      143
      465
      587
      993
    ];

    virtualisation.quadlet =
      let
        inherit (config.virtualisation.quadlet) pods volumes;
        btrfsvol = btrfsVolume config.disko;
      in
      {
        pods.stalwart.podConfig = {
          publishPorts = [
            "25"
            "143"
            "465"
            "587"
            "993"
            "8080"
            "8081"
          ];
        };
        volumes = {
          stalwart = btrfsvol {
            subvol = "@volumes/stalwart";
          };
        };
        containers.stalwart-main = {
          containerConfig = {
            image = "docker.io/stalwartlabs/stalwart:latest";
            pod = pods.stalwart.ref;
            mounts = [
              (mountVolume {
                volume = volumes.stalwart.ref;
                subpath = "/data";
                destination = "/opt/stalwart";
              })
            ];
            environments = {
              STALWART_LOG_LEVEL = "info";
            };
            environmentFiles = [ config.age.secrets."stalwart-env".path ];
            labels = {
              "io.containers.autoupdate" = "registry";
            };
            networks = [ config.virtualisation.quadlet.networks.main.ref ];
          };
        };
      };
  };
}
