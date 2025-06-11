{
  config,
  lib,
  flake,
  ...
}:
let
  inherit (lib) mkIf boolToString mkForce;
  inherit (flake.lib) mkBoolOpt mkStrOpt mkSecret;
  cfg = config.network.tailnet;
in
{
  options.network.tailnet = {
    enable = mkBoolOpt false;
    ip = mkStrOpt "10.64.64.0";
  };

  config = mkIf cfg.enable {
    sys.state.directories = [ "/var/lib/tailscale" ];

    networking.firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ 41641 ];
    };
    services.tailscale = {
      enable = true;
      interfaceName = "ts0";
      authKeyParameters.baseURL = "https://hs.r505.de";
    };
    age.secrets."tailscale-key" = {
      owner = "tailscale";
      file = "tailscale-key";
    };

    networking.firewall.trustedInterfaces = [ "ts0" ];
  };

}
