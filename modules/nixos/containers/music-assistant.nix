{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.music-assistant = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.music-assistant.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.music-assistant.podConfig = {
        publishPorts = ["127.0.0.1:8095:8095"];
      };
      volumes = {
        music-assistant = btrfsvol {
          subvol = "@volumes/music-assistant";
        };
      };
      containers.music-assistant-main = {
        containerConfig = {
          image = "ghcr.io/music-assistant/server:latest";
          pod = pods.music-assistant.ref;
          mounts = [
            (mountVolume {
              volume = volumes.music-assistant.ref;
              subpath = "/data";
              destination = "/data";
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
