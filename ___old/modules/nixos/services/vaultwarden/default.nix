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
        DOMAIN = "https://pw.r505.de";
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;
        INVITATIONS_ALLOWED = true;
        WEB_VAULT_ENABLED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEBSOCKET_ENABLED = false;
      };
      environmentFile = config.age.secrets.vaultwarden-env.path;
    };
    age.secrets.vaultwarden-env.file = ../../../../secrets/vaultwarden.env;

    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [{directory = "/var/lib/bitwarden_rs";}];
    };
    chr.services.cloudflared.enable = true;
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "pw.r505.de" = "http://localhost:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT}";
      };
    };
  };
}
