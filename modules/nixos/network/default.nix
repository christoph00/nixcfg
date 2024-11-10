{ options
, config
, pkgs
, lib
, namespace
, ...
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
    enableDHCPLAN = mkBoolOpt' true;
    enableNM = mkBoolOpt' false;
    enableIWD = mkBoolOpt' cfg.enableWifi;
    lanInterface = mkOption {
      type = types.string;
      default = "en*";
    };

  };

  config = (mkIf cfg.enable) {
    services.resolved = {
      enable = true;
      dnssec = "false";
    };

    networking = {
      useDHCP = false;
      useNetworkd = !cfg.enableNM;

      networkmanager = lib.mkIf cfg.enableNM {
        enable = true;
        wifi.backend = lib.mkIf cfg.enableIWD "iwd";
      };

      wireless.iwd = lib.mkIf cfg.enableIWD {
        enable = true;
        settings.General.EnableNetworkConfiguration = true;
        settings.General.AddressRandomization = "network";
        settings.General.AddressRandomizationRange = "full";
      };

      nftables.enable = true;
      firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [
          80
          443
          22
        ];
      };
    };

    systemd.network = mkIf (!cfg.enableNM) {
      enable = true;
      wait-online.enable = false;
      networks = {
        "20-wireless" = lib.mkIf cfg.enableWifi {
          matchConfig.Name = "wlp*";
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 20;
        };
        "50-wired" = lib.mkIf cfg.enableDHCPLAN {
          matchConfig.Name = cfg.lanInterface;
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 50;
        };
      };
    };

    environment.systemPackages = mkIf cfg.enableIWD [ pkgs.iwgtk ];

    internal.system.state.directories = mkMerge [
      (mkIf cfg.enableIWD [ "/var/lib/iwd" ])
      (mkIf cfg.enableNM [ "/var/lib/NetworkManager" ])
    ];

  };
}
