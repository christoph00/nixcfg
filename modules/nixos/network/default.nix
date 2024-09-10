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
  imports = [ ./tailscale.nix ];

  options.internal.network = with types; {
    enable = mkBoolOpt' true;

  };

  config = (mkIf cfg.enable) {
    networking.networkmanager.enable = mkDefault true;
    networking.wireless.enable = mkDefault false;

    networking.wireless.iwd.settings = mkIf config.internal.isLaptop {
      IPv6 = {
        Enabled = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };

    networking.networkmanager.wifi.backend = "iwd";

    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [
          ""
          "${pkgs.networkmanager}/bin/nm-online -q"
        ];
      };
    };

  };
}
