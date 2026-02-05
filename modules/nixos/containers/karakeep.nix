{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.karakeep = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.karakeep.enable {
    age.secrets."karakeep-env" = mkSecret {
      file = "karakeep-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.karakeep.podConfig = {
        publishPorts = ["127.0.0.1:3000:3000"];
      };
      volumes = {
        karakeep = btrfsvol {
          subvol = "@volumes/karakeep";
        };
      };
      containers.karakeep-main = {
        containerConfig = {
          image = "ghcr.io/karakeepapp/karakeep:latest";
          pod = pods.karakeep.ref;
          mounts = [
            (mountVolume {
              volume = volumes.karakeep.ref;
              subpath = "/data";
              destination = "/data";
            })
          ];
          environments = {
            SERVER_PORT = "3000";
            STORAGE_TYPE = "local";
            STORAGE_LOCAL_PATH = "/data";
            DATABASE_URL = "sqlite:////data/karakeep.db";
          };
          environmentFiles = [config.age.secrets."karakeep-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
