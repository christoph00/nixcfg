  { lib, flake, config, ... }:
  let
    inherit (lib) mkIf;
    inherit (flake.lib) mkBoolOpt;
  in
  {
    options.svc.reverse-proxy = {
      enable = mkBoolOpt false;
      services = lib.mkOption lib.types.submodules {
        inherit (lib.types) str; # Base type for service descriptions
      };
      
      # Add options for each service
      # For example service "example-service"
      options.svc.reverse-proxy.example-service = {
        enable = mkBoolOpt true;
        target = lib.mkOption lib.types.str;
        port = lib.mkOption lib.types.int;
      };
      
      # Use this function to aggregate configurations from all hosts
      config = lib.mkIf config.svc.reverse-proxy.enable {
        networking.proxy.enable = true;
        networking.proxy.reverseProxy = lib.mkIf config.svc.reverse-proxy.enable {
          enable = true;
          hosts = lib.elems (lib.sets.mapAttrs' (service: {
            host = service.target.host;
            port = service.target.port;
          })
          config.svc.reverse-proxy.services);
          
          # Apply create-proxy function for each service
          locations = (config.svc.reverse-proxy.services // lib.toList flake.nixosConfigurations.config.svc.reverse-proxy)
            .locations: lib.elems (config.svc reverse-proxy.services // lib.toList flake.nixosConfigurations.svc.reverse-proxy))
            .locations: lib.elems (lib.mapAttrsToList (serviceName: serviceConfig: let
              proxyConfig = flake.lib.create-proxy {
                inherit (serviceConfig) host port;
                kTLS = true;
                acmeHost = "r505.de";
                aliases = [ "${serviceName}.r505.de" ];
              };
            }));
        };
      };
    };
  }}