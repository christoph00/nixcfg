{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.mosquitto = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.mosquitto.enable {
    age.secrets."mosquitto-env" = mkSecret {
      file = "mosquitto-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.mosquitto.podConfig = {
        publishPorts = ["127.0.0.1:1883:1883" "127.0.0.1:9001:9001"];
      };
      volumes = {
        mosquitto = btrfsvol {
          subvol = "@volumes/mosquitto";
        };
        mosquitto-config = btrfsvol {
          subvol = "@volumes/mosquitto-config";
        };
      };
      containers.mosquitto-main = {
        containerConfig = {
          image = "eclipse-mosquitto:latest";
          pod = pods.mosquitto.ref;
          mounts = [
            (mountVolume {
              volume = volumes.mosquitto.ref;
              subpath = "/data";
              destination = "/mosquitto/data";
            })
            (mountVolume {
              volume = volumes.mosquitto-config.ref;
              subpath = "/config";
              destination = "/mosquitto/config";
            })
          ];
          environments = {
            MOSQUITTO_USERNAME = "mosquitto";
          };
          environmentFiles = [config.age.secrets."mosquitto-env".path];
        };
      };
    };
  };
}
