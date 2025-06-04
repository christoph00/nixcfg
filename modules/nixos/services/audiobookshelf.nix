{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.audiobookshelf.enable {

    sys.state.directories = [ "/var/lib/audiobookshelf" ];

    services.audiobookshelf = {
      port = 5051;
      host = "${config.network.netbird.ip}";
      group = "media";
    };

  };

}
