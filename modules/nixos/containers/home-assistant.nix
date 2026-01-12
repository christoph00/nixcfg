{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.home-assistant = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.home-assistant.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.home-assistant.podConfig = {
        publishPorts = ["127.0.0.1:8123:8123"];
      };
      volumes = {
        home-assistant = btrfsvol {
          subvol = "@volumes/home-assistant";
        };
      };
      containers.home-assistant-main = {
        containerConfig = {
          image = "ghcr.io/home-assistant/home-assistant:stable";
          pod = pods.home-assistant.ref;
          mounts = [
            (mountVolume {
              volume = volumes.home-assistant.ref;
              subpath = "/config";
              destination = "/config";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
          };
          addCapabilities = [
            "CAP_NET_RAW"
            "NET_ADMIN"
            "NET_RAW"
          ]; 
        };
      };
    };
  };
}
