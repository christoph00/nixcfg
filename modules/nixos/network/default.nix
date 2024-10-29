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
    networking.networkmanager.enable = mkDefault false;

    services.resolved = {
      enable = true;
      dnssec = "false";
    };

    networking = {
      useDHCP = false;

      wireless.iwd = {
        enable = config.internal.isLaptop;
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
        "20-wireless" = {
          matchConfig.Name = "wlp*";
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 20;
        };
        "50-wired" = lib.mkIf config.internal.isLaptop {
          matchConfig.Name = "en*";
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 50;
        };
      };
    };

    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [
          ""
          "${pkgs.networkmanager}/bin/nm-online -q"
        ];
      };
    };

    environment.systemPackages = mkIf config.internal.isLaptop [ pkgs.iwgtk ];

  };
}
