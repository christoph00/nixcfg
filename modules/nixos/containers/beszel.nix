{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.beszel = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.beszel.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.beszel.podConfig = {
        publishPorts = ["127.0.0.1:8090:8090"];
      };
      volumes = {
        beszel = btrfsvol {
          subvol = "@volumes/beszel";
        };
      };
      containers.beszel-main = {
        containerConfig = {
          image = "docker.io/henrygd/beszel:latest";
          pod = pods.beszel.ref;
          mounts = [
            (mountVolume {
              volume = volumes.beszel.ref;
              subpath = "/data";
              destination = "/beszel_data";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
          };
        };
      };
    };
  };
}
