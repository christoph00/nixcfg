{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.degoog = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.degoog.enable {
    age.secrets."degoog-env" = mkSecret {
      file = "degoog-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.degoog.podConfig = {
        publishPorts = ["127.0.0.1:4444:4444"];
      };
      volumes = {
        degoog = btrfsvol {
          subvol = "@volumes/degoog";
        };
      };
      containers.degoog-main = {
        containerConfig = {
          image = "ghcr.io/degoog-org/degoog:latest";
          pod = pods.degoog.ref;
          mounts = [
            (mountVolume {
              volume = volumes.degoog.ref;
              subpath = "/data";
              destination = "/app/data";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
          };
          environmentFiles = [config.age.secrets."degoog-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
