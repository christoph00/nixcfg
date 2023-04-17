{
  pkgs,
  lib,
  config,
  ...
}: let
  netIF = "enp1s0";
in {
  boot.kernelModules = [
    "ppp_generic"
    "tcp_bbr"
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
  };

  environment.systemPackages = [pkgs.vnstat];

  networking = {
    useNetworkd = true;
    vlans = {
      "ppp0" = {
        id = 7;
        interface = netIF;
      };
      "lan" = {
        id = 10;
        interface = netIF;
      };
    };
    interfaces = {
      "${netIF}" = {
        useDHCP = false;
      };

      "ppp0".useDHCP = false;

      "lan" = {
        ipv4.addresses = [
          {
            address = "10.10.10.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [];
      };
    };

    firewall = {
      enable = lib.mkForce false;
      allowPing = true;
    };
    nftables = {
      enable = true;
      ruleset = ''
        table ip filter {
          chain output {
            type filter hook output priority 100; policy accept;
          }
          chain input {
            type filter hook input priority filter; policy drop;
            ip saddr 10.0.0.0/8 tcp dport 53 accept;
            ip saddr 10.0.0.0/8 udp dport 53 accept;
            ip saddr 10.0.0.0/8 tcp dport 22 accept;
            ip protocol icmp accept;

            iifname { "lo", "lan"} counter accept
            ip protocol igmp accept comment "accept IGMP"
            ip saddr 224.0.0.0/4 accept
            iifname "pppoe-wan" ct state { established, related } counter accept
            iifname "pppoe-wan" drop
          }

          chain forward {
            meta oiftype ppp tcp flags syn tcp option maxseg size set 1452
            type filter hook forward priority filter; policy drop;

            iifname { "lan" } oifname { "pppoe-wan" } counter accept

            iifname { "pppoe-wan" } oifname { "lan" } ct state established,related counter accept
          }
        }
        table ip nat {
          chain prerouting {
            type nat hook prerouting priority -100; policy accept;
          }

          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            oifname "pppoe-wan" masquerade
          }
        }
      '';
    };
  };

  systemd.network = {
    networks."10-pppoe-wan" = {
      matchConfig = {
        Name = "pppoe-wan";
      };
      networkConfig = {
        IPv6AcceptRA = true;
        KeepConfiguration = true;
        LinkLocalAddressing = "no";
      };
      DHCP = "ipv6";
      dhcpV6Config = {
        WithoutRA = "solicit";
      };
      #      dhcpPrefixDelegationConfig = {
      #  #        UplinkInterface = ":self";
      #        SubnetId = 0;
      #        Announce = false;
      #      };
    };
<<<<<<< Updated upstream
||||||| Stash base
    namespaces.enable = true;`
=======
    namespaces.enable = true;
>>>>>>> Stashed changes
  };

  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          logfile /dev/null
          noipdefault
          noaccomp
          nopcomp
          nocrtscts
          lock
          maxfail 0
          lcp-echo-failure 5
          lcp-echo-interval 1

          nodetach
          ipparam wan
          ifname pppoe-wan
          #nodefaultroute
          defaultroute
          defaultroute6
          usepeerdns
          maxfail 1
          mtu 1492
          mru 1492
          plugin rp-pppoe.so
          # name of the network interface. pppd sometimes claims that this is an invalid
          # option. I assume because the interface doesn't exist at that time.
          nic-ppp0
          user anonymous@t-online.de
          password 12345567
          +ipv6

        '';
        autostart = true;
        enable = true;
      };
    };
  };

  systemd.services."ppp-wait-online" = {
    requires = [
      "systemd-networkd.service"
      "pppd-telekom.service"
    ];
    after = [
      "systemd-networkd.service"
      "pppd-telekom.service"
    ];
    before = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online -i pppoe-wan";
      RemainAfterExit = true;
    };
  };

  systemd.services.nftables = {
    requires = [
      "ppp-wait-online.service"
    ];
    after = [
      "ppp-wait-online.service"
    ];
    before = lib.mkForce [];
  };

  services.lldpd.enable = true;
  services.resolved.enable = lib.mkForce false;

  services.corerad = {
    enable = true;
    settings = {
      interfaces = [
        {
          name = "pppoe-wan";
          monitor = true;
        }
        {
          name = "lan";
          advertise = true;
          prefix = [{prefix = "::/64";}];
          route = [{prefix = "::/0";}];
        }
      ];
    };
  };

  services.vnstat.enable = true;

  services.dnsmasq = {
    enable = true;
    servers = ["193.110.81.0" "185.253.5.0"];
    settings = {
      domain = "lan.net.r505.de";
      interface = ["lan"];
      dhcp-range = ["10.10.10.51,10.10.10.249,24h"];
    };
  };
}
