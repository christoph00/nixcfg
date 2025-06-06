{
  flake,
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;
  cfg = config.svc.mcp-proxy;
  uvx = "${pkgs.uv}/bin/uvx";
  npx = "${pkgs.nodejs}/bin/npx";
  mcpoConfig = {
    mcpServers = {
      github = {
        enabled = true;
        command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
        transportType = "stdio";
        timeout = 120;
        args = [
          "stdio"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "";
        };
      };

      # desktop-commander = {
      #   enabled = true;
      #   transportType = "stdio";
      #   timeout = 120;
      #   command = npx;
      #   args = [
      #     "-y"
      #     "@wonderwhy-er/desktop-commander@latest"
      #   ];
      # };
    };
  };
in
{
  options.svc.mcp-proxy = {
    enable = mkBoolOpt false;
    port = mkIntOpt 3003;
  };

  config = mkIf config.svc.mcp-proxy.enable {
    age.secrets.api-keys-agent = mkSecret {
      file = "api-keys";
      owner = "mcp-proxy";
    };

    sys.state.directories = [ "/var/lib/mcp-proxy" ];
    users.groups.mcp-proxy = { };
    users.users.mcp-proxy = {
      isSystemUser = true;
      createHome = true;
      group = "mcp-proxy";
      home = "/var/lib/mcp-proxy";
    };

    systemd.services.mcp-proxy = {
      script = "${perSystem.self.mcp-proxy}/bin/mcp-proxy --named-server-config ${pkgs.writeText "mcp-proxy-config.json" (builtins.toJSON mcpoConfig)} --port ${toString cfg.port} --stateless ";
      description = "MCP Proxy Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = config.age.secrets.api-keys-agent.file;
        User = "mcp-proxy";
        Group = "mcp-proxy";
        RestartSec = 30;
        WorkingDirectory = "/var/lib/mcp-proxy";
      };
    };
  };

}
