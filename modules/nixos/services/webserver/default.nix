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
      {
        directory = "/var/lib/acme";
        user = config.services.acme.user;
        group = config.services.acme.group;
      }
    ];

    age.secrets.cf-api-key = {
      file = ../../../../secrets/cf-api-key;
      owner = config.services.acme.user;
      group = config.services.acme.group;
    };
    user.extraGroups = [ "nginx" ];

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      clientMaxBodySize = "256k"; # default 10m
      appendConfig = ''pcre_jit on;'';
      commonHttpConfig = ''
        client_body_buffer_size  4k;       # default: 8k
        large_client_header_buffers 2 4k;  # default: 4 8k

        map $sent_http_content_type $expires {
            default                    off;
            text/html                  10m;
            text/css                   max;
            application/javascript     max;
            application/pdf            max;
            ~image/                    max;
        }
      '';
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "chr+acme@asche.co";
        credentialsFile = config.age.secrets.acme.path;
        dnsProvider = "cloudflare";
      };
    };

    users.groups.acme.members = [ "nginx" ];

  };

}
