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

  uvx = "${pkgs.uv}/bin/uvx";
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
      # desktop-commander = {
      #   command = npx;
      #   args = [
      #     "-y"
      #     "@wonderwhy-er/desktop-commander@latest"
      #   ];
      # };
      # # nixos = {
      #   command = "nix";
      #   args = [
      #     "run"
      #     "github:utensils/mcp-nixos"
      #     "--"
      #   ];
      # };
      # # code-reasoning = {
      #   command = npx;
      #   args = [
      #     "-y"
      #     "@mettamatt/code-reasoning"
      #   ];
      # };
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
  options.svc.mcpo = {
    enable = mkBoolOpt false;
    port = mkIntOpt 8787;
  };
  config = mkIf cfg.enable {

    sys.state.directories = [ "/var/lib/mcpo" ];

    # systemd.user.services.mcpo = {
    #   description = "mcpo OpenAPI Server";
    #   wantedBy = [ "default.target" ];
    #   serviceConfig.ExecStart = ''
    #     ${pkgs.uvx}/bin/uvx mcpo --config ${userConfigFile}
    #   '';
    # };

    users.groups.mcpo = { };
    users.users.mcpo = {
      isSystemUser = true;
      createHome = true;
      group = "mcpo";
      home = "/var/lib/mcpo";
    };

    systemd.services.mcpo = {
      description = "mcpo OpenAPI Server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "open-webui.service"
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
        User = "mcpo";
        Group = "mcpo";
        RestartSec = 30;
        WorkingDirectory = "/var/lib/mcpo";
        ExecStart =
          let
            configJSON = pkgs.writeText "config.json" (builtins.toJSON mcpoConfig);
          in
          ''
            ${uvx} mcpo --config ${configJSON} --port ${toString cfg.port}
          '';
      };
    };

  };

}
