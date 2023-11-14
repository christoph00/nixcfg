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
  };
  config = lib.mkIf cfg.enable {
    users.users.caddy.extraGroups = ["acme"];
    services.caddy = {
      enable = true;
      #dataDir = "/var/lib/caddy";
    };
  };
}
