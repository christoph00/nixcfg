{
  config,
  pkgs,
  ...
}: {
  systemd.services.cloudflared = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "Cloudflare Argo Tunnel";
    serviceConfig = {
      EnvironmentFile = config.age.secrets.cloudflared.path;
      TimeoutStartSec = 0;
      Type = "notify";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --metrics localhost:8098 --no-autoupdate run";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
