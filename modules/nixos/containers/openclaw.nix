{
  lib,
  config,
  flake,
  pkgs,
  options,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret mkStrOpt;
  cfg = config.cnt.openclaw;
in {
  options.cnt.openclaw = {
    enable = mkBoolOpt false;
    version = mkStrOpt "v2026.1.29";
    port = mkStrOpt "8999";
  };
  config = mkIf config.cnt.openclaw.enable {
    age.secrets."openclaw-env" = mkSecret {
      file = "openclaw-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes builds;
      btrfsvol = btrfsVolume config.disko;
      src = pkgs.fetchFromGitHub {
        owner = "openclaw";
        repo = "openclaw";
        tag = "${cfg.version}";
        sha256 = "sha256-ZH3j3Sz0uZ8ofbGOj7ANgIW9j+lhknnAsa7ZI0wWo1o=";
      };
    in {
      pods.openclaw.podConfig = {
        publishPorts = ["8999:8999"];
      };
      builds.openclaw.buildConfig = {
        tag = "openclaw:${cfg.version}";
        workdir = "${src}";
        buildArgs= {
          OPENCLAW_DOCKER_APT_PACKAGES="pipx";
        };
      };
      volumes = {
        openclaw = btrfsvol {
          subvol = "@volumes/openclaw";
        };
      };
      containers.openclaw-main = {
        containerConfig = {
          image = builds.openclaw.ref;
          pod = pods.openclaw.ref;
          mounts = [
            (mountVolume {
              volume = volumes.openclaw.ref;
              subpath = "/home";
              destination = "/home/node";
            })
            (mountVolume {
              volume = volumes.openclaw.ref;
              subpath = "/config";
              destination = "/home/node/.openclaw";
            })
            (mountVolume {
              volume = volumes.openclaw.ref;
              subpath = "/workspace";
              destination = "/home/node/.openclaw/workspace";
            })
          ];
          user = "1000";
          group = "100";
          environments = {
            NODE_ENV = "production";
          };
         environmentFiles = [config.age.secrets."openclaw-env".path];
         exec = "node dist/index.js gateway --bind lan --port ${cfg.port} --allow-unconfigured";
         labels = {
           "io.containers.autoupdate" = "local";
         };
        };
      };
    };
  };
}
