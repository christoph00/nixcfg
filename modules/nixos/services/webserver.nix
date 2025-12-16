{
  lib,
  config,
  flake,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (flake.lib) mkBoolOpt mkStrOpt mkSecret;
  cfg = config.svc.webserver;
in {
  options.svc.webserver = {
    enable = mkBoolOpt false;
    domain = mkStrOpt "r505.de";
  };

  config = mkIf cfg.enable {
    sys.state.directories = [
      "/var/lib/acme"
    ];

    age.secrets.cf-api-key = mkSecret {
      file = "cf-api-key";
      owner = "acme";
      group = "acme";
    };

    networking.firewall.allowedTCPPorts = [443];

    services.caddy = {
      enable = true;
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "chr+acme@asche.co";
      };
      certs."${cfg.domain}" = {
        domain = "*.${cfg.domain}";
        # extraDomainNames = [ "*.net.r505.de" ];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        dnsResolver = "1.1.1.1:53";
        credentialsFile = config.age.secrets.cf-api-key.path;
        reloadServices = ["caddy"];
      };
    };
  };
}
