{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.chr.services.home-assistant;
  haDir = config.services.home-assistant.configDir;
in {
  config = lib.mkIf cfg.enable {
    chr.services.webserver.enable = true;

    services.caddy = {
      enable = lib.mkDefault true;
      virtualHosts."${cfg.hostname}" = {
        extraConfig = ''
          reverse_proxy http://[::1]:8123
        '';
      };
    };
  };
}
