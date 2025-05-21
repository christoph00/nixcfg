{
  flake,
  lib,
  options,
  config,
  pkgs,
  ...
}:
with lib;
with flake.lib;
let
  cfg = config.network.router;
in
{

  options.network.router = {
    enable = mkBoolOpt false;
    externalInterface = mkStrOpt "eth0";
    internalInterface = mkStrOpt "eth1";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dnsutils
      dig
      ethtool
      tcpdump
      speedtest-cli
      #netop
    ];

    services.resolved.extraConfig = ''
      DNSStubListener=false
    '';
    services.resolved.fallbackDns = [ "127.0.0.1" ];

    networking = {
      nftables.enable = true;

      nameservers = [
        "::1"
        "127.0.0.1"
      ];
      firewall.allowedTCPPorts = mkForce [ ];
      firewall.allowedUDPPorts = mkForce [ ];
      firewall.interfaces.lan.allowedTCPPorts = [
        53 # dns
        22 # ssh
        8123 # homeassistant
        1883 # mosquitto
        2022 # sftpgo
        80
        443
      ];
      firewall.interfaces.lan.allowedUDPPorts = [
        546 # dhcp
        53 # dns
        67 # dhcp
        68 # dhcp
        5353 # avahi
        123 # ntp
        443
        51820 # wireguard
      ];

      firewall.extraInputRules = ''

        ip6 nexthdr icmpv6 icmpv6 type {
          echo-request,
          destination-unreachable,
          packet-too-big,
          time-exceeded,
          parameter-problem,
          nd-router-advert,
          nd-neighbor-solicit,
          nd-neighbor-advert,
          mld-listener-query
        } accept

        ip protocol icmp icmp type {
          echo-request,
          destination-unreachable,
          router-advertisement,
          time-exceeded,
          parameter-problem
        } accept


         counter drop
      '';

      firewall.filterForward = true;

      firewall.interfaces.dtag-ppp.allowedUDPPorts = [ 546 ];
      firewall.interfaces.dtag-ppp.allowedTCPPorts = [
        # 2022
        # 443
      ];

      firewall.extraForwardRules = ''
        iifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu
        oifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu

        ct state invalid drop
        ct state established,related accept
        iifname lan oifname dtag-ppp ct state new accept

      '';

      # nftables.tables.shaping = {
      #   enable = true;
      #   family = "inet";
      #   name = "shaping";
      #   content = ''
      #     chain postrouting {
      #         type route hook output priority -150; policy accept;
      #         ip daddr != 192.168.0.0/16 jump wan                               # non LAN traffic: chain wan
      #         ip daddr 192.168.0.0/16 meta length 1-64 meta priority set 1:11   # small packets in LAN: priority
      #       }
      #       chain wan {
      #         tcp dport 22 meta priority set 1:21 return                       # SSH traffic -> Internet: priority
      #         tcp dport { 27015, 27036 } meta priority set 1:21 return         # CS traffic -> Internet: priority
      #         udp dport { 27015, 27031-27036 } meta priority set 1:21 return   # CS traffic -> Internet: priority
      #         meta length 1-64 meta priority set 1:21 return                   # small packets -> Internet: priority
      #         meta priority set 1:20 counter                                   # default -> Internet: normal
      #       }
      #   '';
      # };
      nat = {
        enable = true;
        internalInterfaces = [ "lan" ];
        externalInterface = "dtag-ppp";
      };

    };

    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    systemd.network = {
      networks."10-external" = {
        name = cfg.externalInterface;
        DHCP = "no";
        addresses = [ { Address = "10.10.1.2/24"; } ];
        vlan = [ "dtag-wan" ];
        linkConfig.MTUBytes = toString 1600;
      };

      networks."10-internal" = {
        name = cfg.internalInterface;
        DHCP = "no";
        bridge = [ "lan" ];
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

      netdevs."20-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "lan";
        };
      };
      networks."20-lan" = {
        matchConfig = {
          Name = "lan";
          Type = "bridge";
        };
        networkConfig = {
          LinkLocalAddressing = "ipv6";
          IPv6AcceptRA = false;
          IPv6SendRA = true;
          DHCPPrefixDelegation = true;
          DHCPServer = false;
          DNS = [
            "192.168.2.2"
            "fe80::1"
          ];
        };
        addresses = [
          { Address = "192.168.2.2/24"; }
          { Address = "fe80::1/64"; }
        ];
        linkConfig.RequiredForOnline = "routable";
        ipv6SendRAConfig = { };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "dtag-ppp";
          SubnetId = "0x01";
          Announce = "yes";
        };
        dhcpServerConfig = {
          PoolOffset = 20;
        };
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
    services.avahi = {
      enable = true;
      reflector = true;
      allowInterfaces = [
        "lan"
        "ts0"
        "wg0"
      ];
    };

    services.ntpd-rs = enabled;

    services.dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      settings = {
        bind-dynamic = true;
        interface = [ "lan" ];
        dhcp-range = [ "192.168.2.21,192.168.2.249,255.255.255.0,24h" ];
        server = [
          "9.9.9.9"
          "8.8.8.8"
          "1.1.1.1"
          "/ts.r505.de/100.100.100.100"
        ];
        port = 53;
        domain-needed = true;
        bogus-priv = true;
        no-resolv = true;
        cache-size = 1000;

        local = "/lan/";
        domain = "lan";
        expand-hosts = true;

        # no-hosts = true;
        address = "/ha.r505.de/192.168.2.2";
      };
    };

  };

}
