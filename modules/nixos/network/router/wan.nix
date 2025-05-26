{
  config,
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.network.router;
in
{

  config = mkIf cfg.enable {
    systemd.network = {
      networks."10-external" = {
        name = cfg.externalInterface;
        DHCP = "no";
        addresses = [ { Address = "10.10.1.2/24"; } ];
        vlan = [ "dtag-wan" ];
        linkConfig.MTUBytes = toString 1600;
      };
      netdevs."20-dtag-wan" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "dtag-wan";
        };
        vlanConfig.Id = 7;
      };
      networks."20-dtag-wan" = {
        name = "dtag-wan";
        DHCP = "no";
        linkConfig = {
          RequiredForOnline = "degraded";
          RequiredFamilyForOnline = "ipv6";
        };
      };

      networks."20-dtag-ppp" = {
        matchConfig = {
          Name = "dtag-ppp";
          Type = "ppp";
        };
        networkConfig = {
          LinkLocalAddressing = "ipv6";
          DHCP = "ipv6";
        };
        dhcpV6Config = {
          PrefixDelegationHint = "::/56";
          WithoutRA = "solicit";
          UseHostname = "no";
          UseDNS = "no";
          UseNTP = "no";
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = ":self";
          SubnetId = "0";
          Announce = "no";
        };
        # cakeConfig = {
        #   Bandwidth = "150M"; # Upload Bandwidth
        #   CompensationMode = "ptm";
        #   PriorityQueueingPreset = "diffserv4";
        #   FlowIsolationMode = "dual-src-host";
        #   NAT = true;
        # };
      };

    };
    services.pppd = {
      enable = true;
      peers.dtag = {
        config = ''
          plugin pppoe.so dtag-wan
          user anonymous@t-online.de
          password anonymous
          ifname dtag-ppp
          persist
          maxfail 0
          holdoff 5
          noipdefault
          lcp-echo-interval 20
          lcp-echo-failure 3
          mtu 1492
          hide-password
          defaultroute
          +ipv6
          debug
        '';
      };
    };

    systemd.services."pppd-dtag" = {
      partOf = [ "systemd-networkd.service" ];
    };

    systemd.services.check-internet = {
      description = "check ipv4 internet connectivity";
      path = [
        pkgs.iputils
        pkgs.systemd
      ];
      script = ''
        if ! ping -c 3 -W 5 8.8.8.8 >/dev/null 2>&1; then
          systemctl restart pppd-dtag.service
          echo "lost ipv4 connectivity -- restart pppoe"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    systemd.timers.check-internet = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
        Unit = "check-internet.service";
      };
    };
  };

}
