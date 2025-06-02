{
  lib,
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
in
{
  config = mkIf config.services.n8n.enable {
    sys.state.directories = [ "/var/lib/n8n" ];
    services.n8n.webhookUrl = mkDefault "https://n8n.r505.de";
    systemd.services.n8n.path = [
      pkgs.nodejs
      pkgs.uv
      pkgs.bash
      config.nix.package
    ];
    systemd.services.n8n.environment.N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE = "True";
    systemd.services.n8n.serviceConfig = {
      DynamicUser = mkForce false;
      User = "n8n";
      Group = "n8n";
    };
    environment.systemPackages = [
      pkgs.uv
      pkgs.nodejs
    ];

    users.groups.n8n = { };
    users.users.n8n = {
      isSystemUser = true;
      group = "n8n";
      description = "n8n user";
      home = "/var/lib/n8n";
      createHome = true;
    };

  };
}
