{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.nextcloud;
in {
  options.chr.services.nextcloud = with types; {
    enable = mkBoolOpt false "Enable nextcloud Service.";
  };
  config = mkIf cfg.enable {
    chr.services.webserver = {
      enable = true;
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "cloud.r505.de" = "http://127.0.0.1:8070";
      };
    };
  };
}
