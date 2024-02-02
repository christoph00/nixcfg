{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.vaultwarden;
in {
  options.chr.services.vaultwarden = with types; {
    enable = mkBoolOpt false "Enable vaultwarden Service.";
  };
  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://pass.r505.de";
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;
        INVITATIONS_ALLOWED = true;
        WEB_VAULT_ENABLED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEBSOCKET_ENABLED = false;
        DATA_FOLDER = "${config.chr.system.persist.stateDir}/vaultwarden";
      };
      #environmentFile = ;
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "pass.r505.de" = "http://localhost:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT}";
      };
    };
  };
}
