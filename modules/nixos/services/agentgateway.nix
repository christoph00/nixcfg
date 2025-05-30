{
  lib,
  config,
  flake,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt;

  cfg = config.svc.agentgateway;

  uvx = "${pkgs.uv}/bin/uvx";
  npx = "${pkgs.nodejs}/bin/npx";
  agentgatewayConf = {
    type = "static";
    admin = {
      host = "0.0.0.0";
      port = cfg.port;
    };
    listeners = [
      {
        name = "sse";
        protocol = "MCP";
        sse = {
          address = "[::]";
          port = 3000;
        };
      }
    ];
    targets.mcp = [
      {
        name = "fetch";
        stdio = {
          cmd = uvx;
          args = [ "mcp-server-fetch" ];
        };
      }

      # time = {
      #   command = uvx;
      #   args = [
      #     "mcp-server-time"
      #     "--local-timezone=${config.time.timeZone}"
      #   ];
      # };
      # desktop-commander = {
      #   command = npx;
      #   args = [
      #     "-y"
      #     "@wonderwhy-er/desktop-commander@latest"
      #   ];
      # };
      # # nixos = {
      # #   command = "nix";
      # #   args = [
      # #     "run"
      # #     "github:utensils/mcp-nixos"
      # #     "--"
      # #   ];
      # # };
      # # # code-reasoning = {
      # #   command = npx;
      # #   args = [
      # #     "-y"
      # #     "@mettamatt/code-reasoning"
      # #   ];
      # # };
      # searxng = {
      #   command = npx;
      #   args = [
      #     "-y"
      #     "mcp-searxng"
      #   ];
      #   env = {
      #     SEARXNG_URL = "http://127.0.0.1:1033";
      #   };
      # };
      # context7 = {
      #   command = npx;
      #   args = [
      #     "-y"
      #     "@upstash/context7-mcp@latest"
      #   ];
      # };
    ];
  };
in
{
  options.svc.agentgateway = {
    enable = mkBoolOpt false;
    port = mkIntOpt 19000;
  };
  config = mkIf cfg.enable {

    sys.state.directories = [ "/var/lib/agentgateway" ];

    users.groups.agentgateway = { };
    users.users.agentgateway = {
      isSystemUser = true;
      createHome = true;
      group = "agentgateway";
      home = "/var/lib/agentgateway";
    };

    systemd.services.agentgateway = {
      description = " Next Generation Agentic Proxy ";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ];
      environment = {
        UV_NO_MANAGED_PYTHON = "1";
      };
      path = [
        pkgs.nodejs
        pkgs.python3
        pkgs.uv
        pkgs.busybox
        config.nix.package
      ];
      serviceConfig = {
        User = "agentgateway";
        Group = "agentgateway";
        RestartSec = 30;
        WorkingDirectory = "/var/lib/agentgateway";
        ExecStart =
          let
            configJSON = pkgs.writeText "config.json" (builtins.toJSON agentgatewayConf);
          in
          ''
            ${perSystem.self.agentgateway}/bin/agentgateway -f ${configJSON}
          '';
      };
    };

  };

}
