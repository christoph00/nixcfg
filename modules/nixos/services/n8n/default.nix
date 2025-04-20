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
  cfg = config.internal.services.n8n;
  user = "n8n";

in
{

  options.internal.services.n8n = {
    enable = mkBoolOpt false "Enable n8n Service.";
    domain = mkOption {
      type = types.str;
      default = "n8n.r505.de";
      description = "The domain to use for the n8n service.";
    };

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/n8n" ];

    services.caddy.virtualHosts."${cfg.domain}" = {
      extraConfig = # caddyfile
        ''
          encode zstd gzip
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1
          }
          reverse_proxy http://127.0.0.1:${toString config.services.n8n.settings.port}
        '';
    };

    services.n8n = {
      enable = true;

      webhookUrl = "https://${config.internal.services.n8n.domain}";

      settings = {
        generic = {
          timezone = config.time.timeZone;
        };
        endpoints = {
          metrics = {
            enable = false;
          };
        };
      };
    };

    systemd = {
      services.n8n = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = user;
        };
      };
    };

    users = {
      users = {
        n8n = {
          group = user;
          isSystemUser = true;
        };
      };

      groups.n8n = { };
    };

  };

}
