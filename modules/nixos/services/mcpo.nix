{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt;

  cfg = config.svc.mcpo;

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
      desktop-commander = {
        command = npx;
        args = [
          "-y"
          "@wonderwhy-er/desktop-commander@latest"
        ];
      };
      nixos = {
        command = "nix";
        args = [
          "run"
          "github:utensils/mcp-nixos"
          "--"
        ];
      };
      code-reasoning = {
        command = npx;
        args = [
          "-y"
          "@mettamatt/code-reasoning"
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
  options.mcpo = {
    enable = mkBoolOpt false;
    port = mkIntOpt 8787;
  };
  config = mkIf cfg.enable {

    sys.state.directories = [ "/var/lib/private/mcpo" ];

    # systemd.user.services.mcpo = {
    #   description = "mcpo OpenAPI Server";
    #   wantedBy = [ "default.target" ];
    #   serviceConfig.ExecStart = ''
    #     ${pkgs.uvx}/bin/uvx mcpo --config ${userConfigFile}
    #   '';
    # };

    users.users.mcpo = {
      isSystemUser = false;
      createHome = true;
    };

    systemd.services.mcpo = {
      description = "mcpo OpenAPI Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.DynamicUser = true;
      serviceConfig.ExecStart = ''
        ${pkgs.uvx}/bin/uvx mcpo --config ${mcpoConfig} --port ${toString cfg.port}
      '';
    };

  };

}
