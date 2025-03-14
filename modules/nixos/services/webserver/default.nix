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

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [
      {
        directory = "/var/lib/caddy";
        user = config.services.caddy.user;
        group = config.services.caddy.group;
      }
    ];

    age.secrets.cf-api-key = {
      file = ../../../../secrets/cf-api-key;
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };
    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = config.age.secrets.cf-api-key.path;
      AmbientCapabilities = "cap_net_bind_service";
      CapabilityBoundingSet = "cap_net_bind_service";
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ];

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
        ];
        hash = "sha256-JVkUkDKdat4aALJHQCq1zorJivVCdyBT+7UhqTvaFLw=";
      };

      email = "admin@r505.de";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      #logFormat = "level INFO";
      # globalConfig = # caddyfile
      # ''
      #   servers  {
      #      protocols h1 h2
      #    }
      # '';

      #     #     dynamic_dns {
      #       provider cloudflare {env.CLOUDFLARE_API_TOKEN}
      #       domains {
      #         r505.de ha
      #       }
      #       ip_source simple_http https://icanhazip.com
      #       ip_source simple_http https://api64.ipify.org
      #       check_interval 5m
      #       versions ipv4
      #       ttl 5m
      #     }

        # "dns.r505.de" = {
        #   extraConfig = # caddyfile
        #     ''
        #       @denied not remote_ip private_ranges
        #       handle @denied {
        #         abort
        #       }
        #       tls {
        #         dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        #         resolvers 1.1.1.1
        #       }
        #       header -Alt-svc
        #       reverse_proxy http://127.0.0.1:5380
        #     '';
        # };

      };

    };

  };

}
