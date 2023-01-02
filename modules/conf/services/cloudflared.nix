{
  self,
  config,
  pkgs,
  lib,
}: let
  cfg = config.conf.services.cloudflared;
in {
  options = with lib; {
    conf.services.cloudflared = {
      enable = mkEnableOption "Cloudflared Tunnel";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cloudflared = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      description = "Cloudflare Argo Tunnel";
      serviceConfig = {
        EnvironmentFile = config.age.secrets.cloudflare-token.path;
        TimeoutStartSec = 0;
        Type = "notify";
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --metrics localhost:8098 --no-autoupdate run";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
