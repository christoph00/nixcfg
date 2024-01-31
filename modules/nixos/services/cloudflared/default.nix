{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.cloudflared;
in {
  options.chr.services.cloudflared = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable cloudflared Tunnel Service.";
  };
  config = mkIf cfg.enable {
    age.secrets.cf-tunnel = {
      file = ../../../../secrets/cf-tunnel-${config.networking.hostName};
      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;
    };

    boot.kernel.sysctl."net.core.rmem_max" = lib.mkDefault 2500000;
    services.cloudflared.enable = true;
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      default = "http_status:404";
      credentialsFile = config.age.secrets.cf-tunnel.path;
      ingress = {
        "ha.r505.de" = "http://127.0.0.1:8123";
      };
    };
  };
}
