{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
in {
  options.cnt.redlib = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.redlib.enable {
    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods;
    in {
      pods.redlib.podConfig = {
        publishPorts = ["127.0.0.1:8099:8099"];
      };
      containers.redlib = {
        containerConfig = {
          image = "quay.io/redlib/redlib:latest";
          pod = pods.redlib.ref;
          environments = {
            TZ = "Europe/Berlin";
            ENABLE_RSS = "true";
            PORT = "8099";
            THEME = "modusOperandi";
            SHOW_NSFW = "true";
          };
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
    };
  };
}
