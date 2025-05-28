{
  lib,
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.n8n.enable {
    sys.state.directories = [ "/var/lib/private/n8n" ];
    services.n8n.webhookUrl = "https://n8n.r505.de";
    environment.systemPackages = [
      pkgs.uv

      pkgs.nodejs
    ];

  };
}
