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

  cfg = config.svc.mcp-servers;

in
{
  options.svc.mcp-servers = {
    enable = mkBoolOpt false;

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
