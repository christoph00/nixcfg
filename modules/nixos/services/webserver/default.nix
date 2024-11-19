{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
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

  config = mkIf cfg.enable
    {
      age.secrets.cf-api-key.file = ../../../../secrets/cf-api-key;
      systemd.services.caddy.serviceConfig = {
        EnvironmentFile = [
          "${config.age.secrets.cf-api-key.path}"
        ];
      };

      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [

            "github.com/caddy-dns/cloudflare"
            "github.com/mholt/caddy-dynamicdns"
          ];
          hash = "sha256-Im0STQMRadlYCg1SB0Q2U4h38QbSEbpw7Px4bwYizOI=";
        };

        email = "admin@r505.de";
        acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
        globalConfig = # caddyfile
          ''
            dynamic_dns {
              provider cloudflare {env.CLOUDFLARE_API_KEY}
              domains {
                r505.de ddns
              }
              ip_source simple_http https://icanhazip.com
              ip_source simple_http https://api64.ipify.org
              check_interval 5m
              versions ipv4 ipv6
              ttl 5m
            }
          '';
        extraConfig = # caddyfile
          ''
            (acme_r505_de) {
              tls {
                dns cloudflare access_key {env.CLOUDFLARE_API_KEY}
                propagation_timeout -1
              }
            }
            (deny_non_local) {
              @denied not remote_ip private_ranges
              handle @denied {
                abort
              }
            }
          '';
        virtualHosts = {
          "ha.r505.de" = {
            extraConfig = # caddyfile
              ''
                import acme_r505_de
                handle {
                  reverse_proxy http://127.0.0.1:8123 {
                    header_up Host {upstream_hostport}
                  }
                }
              '';
          };

        };

      };

    };

}
