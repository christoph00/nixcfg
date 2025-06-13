{
  lib,
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
  package = pkgs.n8n.overrideAttrs (
    prevAttrs:
    let
      pname = "n8n";
      version = "1.98.1";
      src = pkgs.fetchFromGitHub {
        owner = "n8n-io";
        repo = "n8n";
        tag = "n8n@${version}";
        hash = "sha256-jWRd5Mu7iiisQh/NT7bLCRE9VG6cJ6QTiNWlMk9vnsQ=";
      };

    in
    {
      inherit src version;
      pnpmDeps = pkgs.pnpm_10.fetchDeps {
        inherit pname version src;
        hash = "sha256-gX9rj7MerFH1jdfH0s5/puZaBVF6zR3BpOUac16/B2Y=";
      };
    }
  );
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
      ExecStart = mkForce "${package}/bin/n8n";
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
