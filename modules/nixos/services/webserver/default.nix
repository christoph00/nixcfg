{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.webserver;
in {
  options.chr.services.webserver = with types; {
    enable = mkBoolOpt false "Enable Webserver";
    tlsPolicies = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON TLS policies";
      default = [];
    };
    routes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON routes for http servers";
      default = [];
    };
    blocks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON error blocks for http servers";
      default = [];
    };
    cidrAllowlist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "CIDR blocks to allow for requests";
      default = [];
    };
  };
  config = lib.mkIf cfg.enable {
    chr.services.webserver.cidrAllowlist = ["127.0.0.1/32"];
    chr.services.webserver.routes = [
      {
        match = [{not = [{remote_ip.ranges = cfg.cidrAllowlist;}];}];
        handle = [
          {
            handler = "static_response";
            status_code = "403";
          }
        ];
      }
    ];
    chr.services.webserver.tlsPolicies = [
      {
        issuers = [
          {
            module = "acme";
            challenges = {
              dns = {
                provider = {
                  name = "cloudflare";
                  api_token = "{env.CF_API_TOKEN}";
                };
                resolvers = ["1.1.1.1"];
              };
            };
          }
        ];
      }
    ];
    services.caddy = {
      enable = true;
      adapter = "''"; # Required to enable JSON
      package = pkgs.caddy-cloudflare;
      configFile = pkgs.writeText "Caddyfile" (builtins.toJSON {
        apps.http.servers.main = {
          listen = [":443"];
          routes = cfg.routes;
          errors.routes = cfg.blocks;
          logs = {}; # Uncomment to collect access logs
        };
        apps.http.servers.metrics = {}; # Enables Prometheus metrics
        apps.tls.automation.policies = cfg.tlsPolicies;
        logging.logs.main = {
          encoder = {format = "console";};
          writer = {
            output = "file";
            filename = "${config.services.caddy.logDir}/caddy.log";
            roll = true;
            roll_size_mb = 1;
          };
          level = "INFO";
        };
      });
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets.caddy-env.file = ../../../../secrets/caddy.env;

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = config.age.secrets.caddy-env.path;
        TimeoutStartSec = "5m";
      };
    };
  };
}
