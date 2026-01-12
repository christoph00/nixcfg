{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.jellyfin = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.jellyfin.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.jellyfin.podConfig = {
        publishPorts = ["127.0.0.1:8096:8096" "127.0.0.1:7359:7359/udp" "127.0.0.1:8920:8920"];
      };
      volumes = {
        jellyfin = btrfsvol {
          subvol = "@volumes/jellyfin";
        };
        jellyfin-media = btrfsvol {
          subvol = "@media";
        };
      };
      containers.jellyfin-main = {
        containerConfig = {
          image = "jellyfin/jellyfin:latest";
          pod = pods.jellyfin.ref;
          mounts = [
            (mountVolume {
              volume = volumes.jellyfin.ref;
              subpath = "/config";
              destination = "/config";
            })
            (mountVolume {
              volume = volumes.jellyfin.ref;
              subpath = "/cache";
              destination = "/cache";
            })
            (mountVolume {
              volume = volumes.jellyfin-media.ref;
              subpath = "/media";
              destination = "/media";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
            JELLYFIN_PublishedServerUrl = "https://jellyfin.r505.de";
          };
          addCapabilities = ["NET_ADMIN"];
        };
      };
    };
  };
}
