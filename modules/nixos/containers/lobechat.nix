{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.lobechat = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.lobechat.enable {
    # age.secrets."lobechat-env" = mkSecret {
    #   file = "lobechat-env";
    # };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.lobechat.podConfig = {
        publishPorts = ["127.0.0.1:3210:3210"];
      };
      volumes = {
        lobechat = btrfsvol {
          subvol = "@volumes/lobechat";
        };
      };
      containers.lobechat-main = {
        containerConfig = {
          image = "lobehub/lobe-chat:latest";
          pod = pods.lobechat.ref;
          mounts = [
            (mountVolume {
              volume = volumes.lobechat.ref;
              subpath = "/data";
              destination = "/app/data";
            })
          ];
          environments = {
            PORT = "3210";
            TZ = "Europe/Berlin";
          };
          # environmentFiles = [config.age.secrets."lobechat-env".path];
        };
      };
    };
  };
}
