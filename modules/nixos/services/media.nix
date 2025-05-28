{
  config,
  lib,
  flake,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.svc.media;

in
{

  options.svc.media = {
    enable = mkBoolOpt false;

  };

  config = mkIf cfg.enable {

    sys.state.directories = [
      "/var/lib/jellyfin"
      "/var/cache/jellyfin"
    ];

    services.jellyfin = {
      enable = true;
    };

  };

}
