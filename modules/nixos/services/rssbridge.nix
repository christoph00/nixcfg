{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.rss-bridge.enable {
    sys.state.directories = [ config.services.rss-bridge.dataDir ];
    services.rss-bridge = {
      config = {
        system.enabled_bridges = [ "*" ];
        error = {
          output = "http";
          report_limit = 5;
        };
        FileCache = {
          enable_purge = true;
        };
      };
    };
    services.nginx = {
      enable = true;
      virtualHosts.${config.services.rss-bridge.virtualHost} = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 1035;
            ssl = false;
          }
        ];
      };
    };

  };
}
