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
  cfg = config.internal.services.nas;

in
{

  options.internal.services.nas = {
    enable = mkBoolOpt false "Enable NAS Services.";

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/sftpgo" ];

    services.caddy.virtualHosts."data.r505.de" = {
      extraConfig = # caddyfile
        ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1
          }
          header -Alt-svc
          reverse_proxy /web/* http://127.0.0.1:5102
          reverse_proxy * http://127.0.0.1:5101
        '';
    };

    age.secrets.sftpgo = {
      file = ../../../../secrets/sftpgo.env;
      mode = "0400";
      owner = "sftpgo";
    };
    systemd.services.sftpgo.serviceConfig.EnvironmentFile = config.age.secrets.sftpgo.path;

    services.sftpgo = {
      enable = true;
      user = "sftpgo";
      dataDir = "/var/lib/sftpgo";
      settings = {
        defender.enable = true;
        data_provider = {
          driver = "sqlite";
          name = "sftpgo.db";
          password_hashing = {
            algo = "argon2id";
            argon2_options = {
              memory = 65536;
              iterations = 2;
              parallelism = 2;
            };
          };
          password_caching = true;
          create_default_admin = true;
        };
        webdavd.bindings = [
          {
            address = "127.0.0.1";
            port = 5101;
          }
        ];
        httpd.bindings = [
          {
            address = "127.0.0.1";
            enable_https = false;
            port = 5102;
            client_ip_proxy_header = "X-Forwarded-For";
            enable_web_admin = true;
            enable_web_client = true;
            enable_rest_api = true;
          }
        ];
      };
    };

  };

}
