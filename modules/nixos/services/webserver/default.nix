{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.webserver;

in
{

  options.internal.services.webserver = {
    enable = mkBoolOpt false "Enable Webserver.";
    caddyHash = mkOption {
      type = types.str;
      default = "sha256-exKjrj1XyrmJwHt62HR5GCfFrOZP7P9a1ej+k1LLiVM=";
      description = "Hash of the caddy sources.";
    };

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [
      "/var/lib/acme"
    ];

    age.secrets.cf-api-key = {
      file = ../../../../secrets/cf-api-key;
      owner = "acme";
      group = "acme";
      mode = "440";
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "chr+acme@asche.co";
      };
      certs."r505.de" = {
        domain = "*.r505.de";
        # extraDomainNames = [ "*.net.r505.de" ];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        dnsResolver = "1.1.1.1:53";
        group = "nginx";
        credentialsFile = config.age.secrets.cf-api-key.path;
      };
    };

    users.groups.acme.members = [ "nginx" ];

  };

}
