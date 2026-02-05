{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.gonic = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.gonic.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.gonic.podConfig = {
        publishPorts = ["127.0.0.1:4747:80"];
      };
      volumes.gonic = btrfsvol {
        subvol = "@volumes/gonic";
      };
      containers.gonic-main = {
        containerConfig = {
          image = "docker.io/sentriz/gonic:latest";
          pod = pods.gonic.ref;
          mounts = [
            (mountVolume {
              volume = volumes.gonic.ref;
              subpath = "/data";
              destination = "/data";
            })
            (mountVolume {
              volume = volumes.media.ref;
              subpath = "/music";
              destination = "/music:ro";
            })
            (mountVolume {
              volume = volumes.media.ref;
              subpath = "/podcasts";
              destination = "/podcasts";
            })
            (mountVolume {
              volume = volumes.gonic.ref;
              subpath = "/playlists";
              destination = "/playlists";
            })
            (mountVolume {
              volume = volumes.gonic.ref;
              subpath = "/cache";
              destination = "/cache";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
          };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
