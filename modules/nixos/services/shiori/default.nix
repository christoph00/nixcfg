{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.shiori;
in {
  options.chr.services.shiori = with types; {
    enable = mkBoolOpt false "Enable shiori Service.";
  };
  config = mkIf cfg.enable {
    services.shiori = {
      enable = true;
      port = 9119;
    };
    systemd.services.shiori = {
      serviceConfig = {
        RestrictAddressFamilies = lib.mkForce ["none"];
      };
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "bm.r505.de" = "http://127.0.0.1:9119";
      };
    };
  };
}
