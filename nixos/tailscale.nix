{
  pkgs,
  config,
  ...
}: {
  services.tailscale = {
    enable = true;
  };

  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
  networking.firewall.checkReversePath = "loose";

  systemd.services.tailscale-autoauth = {
    description = "Uses preauth key to connect to tailscale";

    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig.Type = "oneshot";

    script = ''
      ${pkgs.tailscale}/bin/tailscale up --authkey="$(cat ${config.age.secrets.tailscale-preauthkey.path})"
    '';
  };
}
