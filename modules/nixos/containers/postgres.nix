{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.postgres = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.postgres.enable {
    age.secrets."postgres-env" = mkSecret {
      file = "postgres-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.postgres.podConfig = {
        publishPorts = ["127.0.0.1:5432:5432"];
      };
      volumes = {
        postgres = btrfsvol {
          subvol = "@volumes/postgres";
        };
      };
      containers.postgres-main = {
        containerConfig = {
          image = "pgvector/pgvector:pg16";
          pod = pods.postgres.ref;
          mounts = [
            (mountVolume {
              volume = volumes.postgres.ref;
              subpath = "/data";
              destination = "/var/lib/postgresql/data";
            })
          ];
          environments = {
            POSTGRES_USER = "postgres";
            POSTGRES_DB = "postgres";
            PGDATA = "/var/lib/postgresql/data/pgdata";
          };
          environmentFiles = [config.age.secrets."postgres-env".path];
        };
      };
    };
  };
}
