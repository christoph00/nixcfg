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
        };
      };
    };
    internal.system.state.directories = [ "/var/lib/netbird-io" ];
    systemd.services.netbird-netbird-io.postStart = ''
      /run/current-system/sw/bin/netbird-io up
    '';
  };

}
