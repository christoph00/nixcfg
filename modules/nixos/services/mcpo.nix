{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  uvx = "${pkgs.uvx}/bin/uvx";
  npx = "${pkgs.nodejs}/bin/npx";
  mcpoConfig = {
    mcpServers = {
      fetch = {
        command = uvx;
        args = [ "mcp-server-fetch" ];
      };
      time = {
        command = uvx;
        args = [
          "mcp-server-time"
          "--local-timezone=${config.time.timeZone}"
        ];
      };
      searxng = {
        command = npx;
        args = [
          "-y"
          "mcp-searxng"
        ];
        env = {
          SEARXNG_URL = "http://127.0.0.1:1033";
        };
      };
      context7 = {
        command = npx;
        args = [
          "-y"
          "@upstash/context7-mcp@latest"
        ];
      };
    };
  };
in
{
  options.mcpo.enable = mkBoolOpt false;
  config = mkIf config.svc.mcpo.enable {

    sys.state.directories = [ "/var/lib/private/mcpo" ];

    systemd.services.mcpo = {

    };

  };

}
