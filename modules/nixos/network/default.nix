{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.network;
in
{
  options.internal.network = with types; {
    enable = mkBoolOpt' true;

  };

  config = (mkIf cfg.enable){
    networking.networkmanager.enable = mkDefault true;
    networking.wireless.enable = mkDefault false;
    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      };
    };

  };
}
