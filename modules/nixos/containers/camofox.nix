{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.camofox = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.camofox.enable {
    age.secrets."camofox-env" = mkSecret {
      file = "camofox-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.camofox.podConfig = {
        publishPorts = ["127.0.0.1:9377:9377"];
      };
      volumes = {
        camofox = btrfsvol {
          subvol = "@volumes/camofox";
        };
      };
      containers.camofox-main = {
        containerConfig = {
          image = "ghcr.io/jo-inc/camofox-browser:latest";
          pod = pods.camofox.ref;
          mounts = [
            (mountVolume {
              volume = volumes.camofox.ref;
              subpath = "/config";
              destination = "/root/.camofox";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
            PROXY_HOST = "10.100.100.1";
            PROXY_PORT = "3128";
          };
          environmentFiles = [config.age.secrets."camofox-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
