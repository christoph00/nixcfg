{
  lib,
  pkgs,
  config,
  flake,
  ...
}:
let
  inherit (lib) mkIf;
  user = "openwebui";
in
{
  config = mkIf config.services.open-webui.enable {
    services.open-webui = {
      port = 3033;

      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";

        WEBUI_AUTH = "True";
        DEFAULT_LOCALE = "de";

        # Web Search
        ENABLE_RAG_WEB_SEARCH = "True";
        SEARXNG_QUERY_URL = "http://127.0.0.1:1033/search?q=<query>";
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
