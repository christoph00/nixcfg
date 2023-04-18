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

    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
  };

  environment.systemPackages = [pkgs.vnstat];

  networking = {
    useNetworkd = true;
    nat.enable = false;
    firewall = {
      enable = lib.mkForce false;
      allowPing = true;
    };
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
    networks = {
      "40-pppoe-wan" = {
        matchConfig = {
          Name = "pppoe-wan";
        };
        networkConfig = {
          IPv6AcceptRA = true;
          LinkLocalAddressing = "ipv6";
          DNS = "127.0.0.1";
          DHCP = "ipv6";
          IPForward = "yes";
          IPv6PrivacyExtensions = "kernel";
          IPv6DuplicateAddressDetection = 1;
          KeepConfiguration = "static";
          DefaultRouteOnDevice = true;
        };
        DHCP = "ipv6";
        dhcpV6Config = {
          UseDNS = false;
          UseNTP = false;
          WithoutRA = "solicit";
          PrefixDelegationHint = "::/56";
        };
        cakeConfig = {
          OverheadBytes = 65;
          Bandwidth = "40M";
        };
      };
      "40-lan" = {

         networkConfig.
      dhcpServerConfig = {
        EmitRouter = true;
        Router = "192.168.100.2";
      };

        networkConfig = {
          DHCPServer = true;
          EmitLLDP = true;
          IPv6SendRA = true;
        };
        dhcpPrefixDelegationConfig = {
          SubnetId = "0x1";
        };
      };
    };
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

  services.udev.packages = [
    (pkgs.writeTextFile rec {
      name = "accept_ra_for_pppoe.rules";
      destination = "/etc/udev/rules.d/99-${name}";
      # test with: nixos-rebuild test && udevadm control --log-priority=debug && udevadm trigger /sys/devices/virtual/net/pppoe-wan --action=add
      text = ''
        #
        ACTION=="add|change|move", SUBSYSTEM=="net", ENV{INTERFACE}=="pppoe-wan", RUN+="${pkgs.procps}/bin/sysctl net.ipv6.conf.pppoe-wan.accept_ra=2"
      '';
    })
  ];

  systemd.services.pppd-telekom.serviceConfig.ReadWritePaths = ["/etc/ppp"];

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

  services.resolved.enable = lib.mkForce false;

  # services.dnsmasq = {
  #   enable = true;
  #   resolveLocalQueries = true;
  #   settings = {
  #     port = 5300;
  #     domain = "lan.net.r505.de";
  #     domain-needed = true;
  #     local = ["/lan.net.r505.de/"];
  #     interface = ["lan"];
  #     dhcp-range = ["10.10.10.51,10.10.10.249,24h"];
  #     dhcp-authoritative = true;
  #     dhcp-option = ["option:dns-server,0.0.0.0"];
  #   };
  # };

  services.blocky = {
    enable = true;
    settings = {
      upstream.default = [
        "tcp-tls:fdns1.dismail.de:853"
        "https://dns.telekom.de/dns-query"
        "https://dns.digitale-gesellschaft.ch/dns-query"
        "https://dnsforge.de/dns-query"
      ];
      startVerifyUpstream = true;
      blocking = {
        blackLists.default = [
          "https://adaway.org/hosts.txt"
          "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
        ];
        clientGroupsBlock.default = ["default"];
      };
      caching.maxTime = "30m";
      prometheus.enable = true;
      port = "0.0.0.0:53";
      httpPort = 4000;
      bootstrapDns = "tcp+udp:1.1.1.1";
      ede.enable = true;
      conditional = {
        mapping = {
          "lan.net.r505.de" = "127.0.0.1:5300";
        };
      };
    };
  };
}
