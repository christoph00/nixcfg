{
  lib,
  config,
  pkgs,
  perSystem,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  package = perSystem.nixpkgs-unstable.n8n.overrideAttrs (old: {
    meta =
      old.meta
      // {
        license = lib.licenses.free;
      };
  });
in {
  config = mkIf config.services.n8n.enable {
    sys.state.directories = ["/var/lib/n8n"];
    services.n8n.environment.WEBHOOK_URL = mkDefault "https://n8n.r505.de";

    systemd.services.n8n.path = [
      pkgs.nodejs
      pkgs.uv
      pkgs.bash
      config.nix.package
    ];
    systemd.services.n8n.environment.N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE = "True";
    systemd.services.n8n.serviceConfig = {
      DynamicUser = mkForce false;
      ExecStart = mkForce "${package}/bin/n8n";
      User = "n8n";
      Group = "n8n";
    };
    environment.systemPackages = [
      pkgs.uv
      pkgs.nodejs
    ];

    users.groups.n8n = {};
    users.users.n8n = {
      isSystemUser = true;
      group = "n8n";
      description = "n8n user";
      home = "/var/lib/n8n";
      createHome = true;
    };
  };
}
