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
  inherit (flake.lib) mkBoolOpt mkIntOpt;
  cfg = config.svc.mcp-proxy;
  uvx = "${pkgs.uv}/bin/uvx";
  npx = "${pkgs.nodejs}/bin/npx";
  mcpoConfig = {
    mcpServers = {
      fetch = {
        enabled = true;
        transportType = "stdio";
        timeout = 120;
        command = uvx;
        args = [ "mcp-server-fetch" ];
      };
      time = {
        enabled = true;
        transportType = "stdio";
        timeout = 120;
        command = uvx;
        args = [
          "mcp-server-time"
          "--local-timezone=${config.time.timeZone}"
        ];
      };
      desktop-commander = {
        enabled = true;
        transportType = "stdio";
        timeout = 120;
        command = npx;
        args = [
          "-y"
          "@wonderwhy-er/desktop-commander@latest"
        ];
      };
    };
  };
in
{
  options.svc.mcp-proxy = {
    enable = mkBoolOpt false;
    port = mkIntOpt 3003;
  };

  config = mkIf config.svc.mcp-proxy.enable {

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
        User = "mcp-proxy";
        Group = "mcp-proxy";
        RestartSec = 30;
        WorkingDirectory = "/var/lib/mcp-proxy";
      };
    };
  };

}
