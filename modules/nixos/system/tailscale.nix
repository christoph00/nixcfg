{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib; {
  config = mkIf (config.nos.network.tailscale.enable) {
    # make the tailscale command usable to users
    environment.systemPackages = [pkgs.tailscale];

    age.secrets.tailscaleAuthKey.file = "${self}/secrets/tailscale-preauthkey";

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = ["tailscale0"];
      checkReversePath = "loose";

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];
    };

    # enable tailscale, inter-machine VPN service
    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = "client";
      authKeyFile = lib.mkDefault config.age.secrets.tailscaleAuthKey.path;
    };

    age.secrets.tailscale-tsnsrv = {
      file = "${self}/secrets/tailscale-tsnsrv";
      group = config.users.groups.tsnsrv.name;
      mode = "770";
    };

    services.tsnsrv = {
      enable = true;
      defaults = {
        authKeyPath = lib.mkDefault config.age.secrets.tailscale-tsnsrv.path;
      };
    };
  };
}
