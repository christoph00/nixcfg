{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.tinyauth = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.tinyauth.enable {
    age.secrets."tinyauth-env" = mkSecret {
      file = "tinyauth-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.tinyauth.podConfig = {
        publishPorts = ["127.0.0.1:3000:3000"];
      };
      volumes = {
        tinyauth = btrfsvol {
          subvol = "@volumes/tinyauth";
        };
      };
      containers.tinyauth-main = {
        containerConfig = {
          image = "ghcr.io/tinyauthapp/tinyauth:v5";
          pod = pods.tinyauth.ref;
          mounts = [
            (mountVolume {
              volume = volumes.tinyauth.ref;
              subpath = "/data";
              destination = "/data";
            })
          ];
          environments = {
            TZ = "Europe/Berlin";
            TINYAUTH_APPURL = "https://a.r505.de";
            TINYAUTH_DATABASE_PATH = "/data/tinyauth.db";
            TINYAUTH_AUTH_USERSFILE = "/data/users";
            TINYAUTH_UI_TITLE = "auth";
          };
          environmentFiles = [config.age.secrets."tinyauth-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
