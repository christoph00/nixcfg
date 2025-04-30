{
  config,
  options,
  lib,
  ...
}:
with lib;
with lib.internal;

let
  cfg = config.internal.network.netbird;
in
{
  options.internal.network.netbird = {
    enable = mkBoolOpt true "Enable Netbird";
  };

  config = mkIf cfg.enable {
    services.netbird = {
      enable = true;
      clients = {
        io = {
          port = 51820;
          environment.NB_SETUP_KEY_FILE = config.age.secrets."netbird-io-setup-key".path;
          dns-resolver.address = "127.0.0.1";
          dns-resolver.port = 5333;
        };
      };
    };
    internal.system.state.directories = [ "/var/lib/netbird-io" ];
    age.secrets."netbird-io-setup-key" = {
      owner = "netbird-io";
      file = ../../../secrets/netbird-io-setup.key;
    };
    systemd.services.netbird-io.postStart = ''
      /run/current-system/sw/bin/netbird-io up
    '';

    networking.firewall.trustedInterfaces = [ "nb-io" ];
  };

}
