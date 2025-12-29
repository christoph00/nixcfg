{
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
in
{
  config = mkIf config.services.stalwart-mail.enable {
    sys.state.directories = [ "/var/lib/stalwart-mail" ];

    services.stalwart-mail = {
      openFirewall = true;
      settings = {
        server = {
          hostname = "mx.r505.de";
          tls = {
            enable = true;
            implicit = true;
          };
          listener = {
            smtp = {
              protocol = "smtp";
              bind = "[::]:25";
            };
            submissions = {
              bind = "[::]:465";
              protocol = "smtp";
              tls.implicit = true;
            };
            imaps = {
              bind = "[::]:993";
              protocol = "imap";
              tls.implicit = true;
            };
            jmap = {
              bind = "127.0.0.1:8087";
              url = "https://jmap.r505.de";
              protocol = "http";
            };
            management = {
              bind = [ "127.0.0.1:8088" ];
              protocol = "http";
            };
          };
        };
        session.auth = {
          mechanisms = "[plain]";
          directory = "'in-memory'";
        };
        jmap = {
          http.headers = [
            "Access-Control-Allow-Origin: *"
            "Access-Control-Allow-Methods: POST, GET, HEAD, OPTIONS"
            "Access-Control-Allow-Headers: *"
          ];
        };
      };
    };
  };
}
