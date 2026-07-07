{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.vaultwarden = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.vaultwarden.enable {
    age.secrets."vaultwarden-env" = mkSecret {
      file = "vaultwarden-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.vaultwarden.podConfig = {
        publishPorts = ["127.0.0.1:8222:80"];
      };
      volumes = {
        vaultwarden = btrfsvol {
          subvol = "@volumes/vaultwarden";
        };
      };
      containers.vaultwarden-main = {
        containerConfig = {
          image = "docker.io/vaultwarden/server:latest";
          pod = pods.vaultwarden.ref;
          mounts = [
            (mountVolume {
              volume = volumes.vaultwarden.ref;
              subpath = "/data";
              destination = "/data";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
            DOMAIN = "https://pw.r505.de";
            PUSH_ENABLED = "true";
            PUSH_RELAY_URI = "https://api.bitwarden.eu";
            PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
          };
          environmentFiles = [config.age.secrets."vaultwarden-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
