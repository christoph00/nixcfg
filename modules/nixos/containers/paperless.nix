{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.paperless = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.paperless.enable {
    age.secrets."paperless-env" = mkSecret {
      file = "paperless-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.paperless.podConfig = {
        publishPorts = ["127.0.0.1:8000:8000"];
      };
      volumes = {
        paperless = btrfsvol {
          subvol = "@volumes/paperless";
        };
      };
      containers.paperless-main = {
        containerConfig = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
          pod = pods.paperless.ref;
          mounts = [
            (mountVolume {
              volume = volumes.paperless.ref;
              subpath = "/data";
              destination = "/usr/src/paperless/data";
            })
          ];
          user = "1000";
          group = "100";
          environments = {
          };
          environmentFiles = [config.age.secrets."paperless-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
