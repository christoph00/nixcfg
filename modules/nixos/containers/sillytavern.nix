{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.sillytavern = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.sillytavern.enable {
    age.secrets."sillytavern-env" = mkSecret {
      file = "sillytavern-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.sillytavern.podConfig = {
        publishPorts = ["8000:8000"];
      };
      volumes = {
        sillytavern = btrfsvol {
          subvol = "@volumes/sillytavern";
        };
      };
      containers.sillytavern-main = {
        containerConfig = {
          image = "ghcr.io/sillytavern/sillytavern:staging";
          pod = pods.sillytavern.ref;
          mounts = [
            (mountVolume {
              volume = volumes.sillytavern.ref;
              subpath = "/config";
              destination = "/home/node/app/config";
            })
            (mountVolume {
              volume = volumes.sillytavern.ref;
              subpath = "/data";
              destination = "/home/node/app/data";
            })
            (mountVolume {
              volume = volumes.sillytavern.ref;
              subpath = "/plugins";
              destination = "/home/node/app/plugins";
            })
            (mountVolume {
              volume = volumes.sillytavern.ref;
              subpath = "/extensions";
              destination = "/home/node/app/public/scripts/extensions/third-party";
            })
          ];
          # user = "1000";
          # group = "100";
          environments = {
            NODE_ENV = "production";
          };
          environmentFiles = [config.age.secrets."sillytavern-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
