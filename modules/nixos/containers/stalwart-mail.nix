{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.stalwart-mail = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.stalwart-mail.enable {
    age.secrets."stalwart-mail-env" = mkSecret {
      file = "stalwart-mail-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.stalwart-mail.podConfig = {
        publishPorts = [
          "127.0.0.1:25:25"
          "127.0.0.1:143:143"
          "127.0.0.1:465:465"
          "127.0.0.1:587:587"
          "127.0.0.1:993:993"
        ];
      };
      volumes = {
        stalwart-mail = btrfsvol {
          subvol = "@volumes/stalwart-mail";
        };
        stalwart-mail-data = btrfsvol {
          subvol = "@volumes/stalwart-mail-data";
        };
      };
      containers.stalwart-mail-main = {
        containerConfig = {
          image = "docker.io/stalwartlabs/mail-server:latest";
          pod = pods.stalwart-mail.ref;
          mounts = [
            (mountVolume {
              volume = volumes.stalwart-mail.ref;
              subpath = "/etc";
              destination = "/etc/stalwart-mail";
            })
            (mountVolume {
              volume = volumes.stalwart-mail-data.ref;
              subpath = "/data";
              destination = "/opt/stalwart-mail";
            })
          ];
          environments = {
            STALWART_LOG_LEVEL = "info";
          };
          environmentFiles = [config.age.secrets."stalwart-mail-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
