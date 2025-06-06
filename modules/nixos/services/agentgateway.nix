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
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;

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
      # {
      #   name = "github";
      #   listeners = [ "sse" ];
      #   stdio = {
      #     cmd = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      #     args = [
      #       "stdio"
      #     ];
      #     env = {
      #       GITHUB_PERSONAL_ACCESS_TOKEN = "$(awk -F'=' '/^GITHUB_PERSONAL_ACCESS_TOKEN=/ {print $2}' ${config.age.secrets.api-keys-agent.path})";
      #     };
      #   };
      # }
      # # {
      #   name = "fetch";
      #   listeners = [ "sse" ];
      #   stdio = {
      #     cmd = uvx;
      #     args = [
      #       "-p"
      #       "3.12"
      #       "mcp-server-fetch"
      #     ];
      #   };
      # }
      # {
      #   name = "time";
      #   listeners = [ "sse" ];
      #   stdio = {
      #     cmd = uvx;
      #     args = [
      #       "mcp-server-time"
      #       "--local-timezone=${config.time.timeZone}"
      #     ];
      #   };
      # }
      #
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
    age.secrets.api-keys-agent = mkSecret {
      file = "api-keys";
      owner = "agentgateway";
    };

    environment.systemPackages = [
      pkgs.github-mcp-server
      pkgs.uv
      pkgs.nodejs
    ];

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
