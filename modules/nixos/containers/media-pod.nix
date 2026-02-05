{
  lib,
  config,
  flake,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
  cfg = config.cnt.media-pod;
in {
  options.cnt.media-pod = {
    enable = mkBoolOpt false;
    jellyfin = mkBoolOpt true;
    altmount = mkBoolOpt true;
    nzbdav = mkBoolOpt false;
  };
  config = mkIf config.cnt.media-pod.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.media.podConfig = {
        publishPorts = ["8096:8096" "8080:8080" "3000:3000"];
      };
      volumes = {
        jellyfin = btrfsvol {
          subvol = "@volumes/jellyfin";
        };
        media = btrfsvol {
          subvol = "@media";
        };
        altmount = btrfsvol {
          subvol = "@volumes/altmount";
        };
        nzbdav = btrfsvol {
          subvol = "@volumes/nzbdav";
        };
      };
      containers.jellyfin = {
        containerConfig = {
          image = "docker.io/jellyfin/jellyfin:latest";
          pod = pods.media.ref;
          mounts = [
            (mountVolume {
              volume = volumes.jellyfin.ref;
              subpath = "/config";
              destination = "/config";
            })
            (mountVolume {
              volume = volumes.jellyfin.ref;
              subpath = "/cache";
              destination = "/cache";
            })
            (mountVolume {
              volume = volumes.media.ref;
              subpath = "/";
              destination = "/media";
            })
          ];
          # volumes = ["/mnt/dav:/mnt/dav"];
          environments = {
            TZ = "Europe/Berlin";
            JELLYFIN_PublishedServerUrl = "https://media.r505.de";
          };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
      containers.nzbdav.containerConfig = mkIf cfg.nzbdav {
        image = "ghcr.io/nzbdav-dev/nzbdav:latest";
        pod = pods.media.ref;
        mounts = [
          (mountVolume {
            volume = volumes.media.ref;
            subpath = "/";
            destination = "/media";
          })
          (mountVolume {
            volume = volumes.nzbdav.ref;
            subpath = "/config";
            destination = "/config";
          })
        ];
        environments = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
        };
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
      containers.altmount = mkIf cfg.altmount {
        containerConfig = {
          image = "ghcr.io/javi11/altmount:latest";
          pod = pods.media.ref;
          mounts = [
            (mountVolume {
              volume = volumes.altmount.ref;
              subpath = "/config";
              destination = "/config";
            })
            (mountVolume {
              volume = volumes.media.ref;
              subpath = "/";
              destination = "/media";
            })
          ];
          environments = {
            PUID = "1000";
            PGID = "1000";
            PORT = "8080";
            COOKIE_DOMAIN = "10.100.100.21";
            TZ = "Europe/Berlin";
          };
          addCapabilities = ["SYS_ADMIN"];
          devices = ["/dev/fuse"];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
    #   age.secrets.rclone-conf = mkSecret {
    #     file = "rclone-conf";
    #   };
    #
    #   environment.systemPackages = [pkgs.rclone];
    #   fileSystems."/mnt/dav" = {
    #     device = "nzbdav:/media";
    #     fsType = "rclone";
    #     options = [
    #       "nodev"
    #       "nofail"
    #       "allow_other"
    #       "gid=1000"
    #       "uid=1000"
    #       "args2env"
    #       "x-systemd.automount"
    #       "x-systemd.mount-timeout=86400s"
    #       "x-systemd.after=nzbdav.service"
    #       "config=${config.age.secrets.rclone-conf.path}"
    #     ];
    #   };
  };
}
