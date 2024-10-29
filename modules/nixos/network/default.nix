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
    enableWifi = mkBoolOpt' config.internal.isLaptop;


  };

  config = (mkIf cfg.enable) {
    networking.networkmanager.enable = mkDefault false;

    services.resolved = {
      enable = true;
      dnssec = "false";
    };

    networking = {
      useDHCP = false;

      wireless.iwd = {
        enable = cfg.enableWifi;
        settings.General.EnableNetworkConfiguration = true;
        settings.General.AddressRandomization = "network";
        settings.General.AddressRandomizationRange = "full";
      };

      nftables.enable = true;
      firewall = {
        enable = true;
        allowPing = true;
      };
    };

    systemd.network = {
      enable = true;
      wait-online.enable = false;
      networks = {
        "20-wireless" = lib.mkIf cfg.enableWifi {
          matchConfig.Name = "wlp*";
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 20;
        };
        "50-wired" =  {
          matchConfig.Name = "en*";
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 50;
        };
      };
    };

    environment.systemPackages = mkIf cfg.enableWifi [ pkgs.iwgtk ];

  };
}
