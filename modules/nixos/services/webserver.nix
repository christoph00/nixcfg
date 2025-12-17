{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkForce
    mapAttrs'
    mapAttrsToList
    nameValuePair
    filterAttrs
    types
    ;
  inherit (flake.lib)
    mkBoolOpt
    mkStrOpt
    mkSecret
    mkOpt
    ;
  cfg = config.svc.webserver;

in
{
  options.svc.webserver = {
    enable = mkBoolOpt false;
    domain = mkStrOpt "r505.de";

    # Service definitions - each service can be enabled and configured in host configs
    services = lib.mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkBoolOpt false;
          subdomain = mkStrOpt "";
          port = lib.mkOption { type = types.int; default = 80; };
          host = mkStrOpt "127.0.0.1";
          extraConfig = mkStrOpt "";
          extraHeaders = lib.mkOption { type = types.attrsOf types.str; default = {}; };
        };
      });
      default = {};
      description = "Service definitions for webserver reverse proxy";
    };
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

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Increase network buffer sizes system-wide for better performance
    boot.kernel.sysctl = {
      "net.core.rmem_default" = 262144;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_default" = 262144;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 65536 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    };

    systemd.services.caddy.serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      ReadWritePaths = [ "/var/lib/caddy" "/var/lib/acme" ];
    };

    services.caddy = {
      enable = true;
      # Configure FrankenPHP
      # package = pkgs.frankenphp;
     
      # Generate virtual hosts for enabled services
      virtualHosts =
        let
          enabledServices = filterAttrs (_: service: service.enable) cfg.services;
        in
        mapAttrs'
          (_name: service: {
            name = "${service.subdomain}.${cfg.domain}";
            value = {
              extraConfig = ''
                reverse_proxy http://${service.host}:${toString service.port}
                ${service.extraConfig}
              '';
            };
          })
          enabledServices;
    };

    users.users.caddy.extraGroups = [ "acme" ];
    systemd.tmpfiles.rules = [
      "Z /var/lib/acme 0755 acme acme - -"
    ];

    # Dynamic ACME certificate generation for all enabled services
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "chr+acme@asche.co";
        dnsProvider = "cloudflare";
        #dnsPropagationCheck = true;
        #dnsResolver = "1.1.1.1:53";
        credentialsFile = config.age.secrets.cf-api-key.path;
        reloadServices = [ "caddy.service" ];
        # Use lego client instead of minica for cloudflare DNS
        server = "https://acme-v02.api.letsencrypt.org/directory";
      };
      # Generate certs for each enabled service
      certs =
        let
          enabledServices = filterAttrs (_: service: service.enable) cfg.services;
        in
        mapAttrs'
          (_name: service: {
            name = "${service.subdomain}.${cfg.domain}";
            value = {
              domain = "${service.subdomain}.${cfg.domain}";
              reloadServices = [ "caddy.service" ];
            };
          })
          enabledServices;
    };
  };
}
