{
  options,
  config,
  lib,
  flake,
  pkgs,
  ...
}:
with lib;
with flake.lib; let
  inherit (lib) mkDefault;
  cfg = config.network;
in {
  imports = [
    ./router
    ./optimize.nix
    ./wireguard.nix
  ];

  options.network = with types; {
    enable = mkBoolOpt true;
    enableWifi = mkBoolOpt false;
    enableDHCPLAN = mkBoolOpt true;
    enableNM = mkBoolOpt config.host.graphical;
    lanInterface = mkStrOpt "en*";
    publicIP = mkStrOpt "dynamic";
    wgIP = mkStrOpt "10.100.100.99";
  };

  config = (mkIf cfg.enable) {
    services.resolved = {
      enable = mkDefault true;
      dnssec = "allow-downgrade";
      fallbackDns = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      llmnr = "true";
      extraConfig = ''
        Domains=~.
        MulticastDNS=true
      '';
    };

    system.nssDatabases.hosts = mkMerge [
      (mkBefore ["mdns_minimal [NOTFOUND=return]"])
      (mkAfter ["mdns"])
    ];

    hardware.wirelessRegulatoryDatabase = mkDefault cfg.enableWifi;

    networking = {
      hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
      useDHCP = false;
      useNetworkd = !cfg.enableNM;

      domain = mkDefault "r505.de";

      networkmanager.wifi.backend = "iwd";
      networkmanager.enable = cfg.enableNM;
      networkmanager.dns = "systemd-resolved";

      wireless = mkIf cfg.enableWifi {
        enable = false;
        iwd = {
          enable = mkIf (!cfg.enableNM) true;
          settings.General.EnableNetworkConfiguration = true;
          settings.Settings.AutoConnect = true;
        };
      };

      nftables.enable = mkDefault true;
      firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [
          80
          443
          22
        ];
        allowedUDPPorts = [
          51820
        ];
      };
    };

    systemd.network = mkIf (!cfg.enableNM) {
      enable = true;
      wait-online.anyInterface = true;
      networks = {
        "20-wireless" = mkIf cfg.enableWifi {
          matchConfig.Name = ["wlp*" "wlan*"];
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 20;
        };
        "50-wired" = mkIf cfg.enableDHCPLAN {
          matchConfig.Name = cfg.lanInterface;
          networkConfig.DHCP = "yes";
          dhcpConfig.RouteMetric = 50;
        };
      };
    };

    environment.systemPackages = mkIf cfg.enableWifi [pkgs.iwgtk];

    sys.state.directories = mkMerge [
      (mkIf cfg.enableWifi ["/var/lib/iwd"])
      (mkIf cfg.enableNM [
        "/var/lib/NetworkManager"
        "/etc/NetworkManager/system-connections"
      ])
    ];
  };
}
