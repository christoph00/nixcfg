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
  cfg = config.internal.services.ai;
  user = "openwebui";

in
{

  options.internal.services.ai = {
    enable = mkBoolOpt false "Enable ai Services.";
    domain = mkOption {
      type = types.str;
      default = "ai.r505.de";
      description = "The domain to use for the ai services.";
    };

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/open-webui" ];

    services.nginx.virtualHosts."${cfg.domain}" = {
      useACMEHost = "r505.de";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.open-webui.port}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header        X-Forwarded-Proto $scheme;
          proxy_set_header        X-Forwarded-Host $host;
          proxy_set_header        X-Forwarded-Server $host;
        '';
      };
    };
    services.open-webui = {
      enable = true;
      package = pkgs.open-webui;
      port = 3000;

      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";

        WEBUI_AUTH = "True";
        DEFAULT_LOCALE = "de";

        # Web Search
        ENABLE_RAG_WEB_SEARCH = "True";
        SEARXNG_QUERY_URL = "https://priv.au/search?q=<query>";
        RAG_WEB_SEARCH_ENGINE = "searxng";

      };
    };

    systemd = {
      services.open-webui = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = user;
        };
      };
    };

    users = {
      users = {
        openwebui = {
          group = user;
          isSystemUser = true;
        };
      };

      groups.openwebui = { };
    };

  };

}
