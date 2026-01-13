{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.qdrant = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.qdrant.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.qdrant.podConfig = {
        publishPorts = ["6333:6333" "6334:6334"];
      };
      volumes = {
        qdrant = btrfsvol {
          subvol = "@volumes/qdrant";
        };
      };
      containers.qdrant-main = {
        containerConfig = {
          image = "docker.io/qdrant/qdrant";
          pod = pods.qdrant.ref;
          mounts = [
            (mountVolume {
              volume = volumes.qdrant.ref;
              subpath = "/storage";
              destination = "/qdrant/storage";
            })
          ];
          environments = {
            TZ = config.time.timeZone;
          };
        };
      };
    };
  };
}
