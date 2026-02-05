{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.cliproxy = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.cliproxy.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.cliproxy.podConfig = {
        publishPorts = ["8317:8317"];
      };
      volumes = {
        cliproxy = btrfsvol {
          subvol = "@volumes/cliproxy";
        };
      };
      containers.cliproxy-main = {
        containerConfig = {
          image = "docker.io/eceasy/cli-proxy-api-plus:latest";
          pod = pods.cliproxy.ref;
          mounts = [
            (mountVolume {
              volume = volumes.cliproxy.ref;
              subpath = "/config/config.yaml";
              destination = "/CLIProxyAPI/config.yaml";
            })
            (mountVolume {
              volume = volumes.cliproxy.ref;
              subpath = "/data";
              destination = "/.cli-proxy-api";
            })
            (mountVolume {
              volume = volumes.cliproxy.ref;
              subpath = "/logs";
              destination = "/CLIProxyAPI/logs";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
          };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
