{
  pkgs,
  lib,
  config,
  ...
}: {
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

    "net.ipv4.tcp_rmem" = "4096 87380 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";
    "net.core.rmem_max" = 67108864;
    "net.core.wmem_max" = 67108864;
  };

  environment.systemPackages = [pkgs.nftables];

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
        interface = "enp5s0";
      };
    };

    # bridges.lan.interfaces = ["enp3s0f0" "enp3s0f1" "enp4s0f0" "enp4s0f1"];
    bridges.br-lan0.interfaces = ["lan0" "lan1" "lan2" "lan3"];
    interfaces = {
      "ppp0" = {
        ipv4.addresses = [];
        ipv6.addresses = [];
      };

      "lan" = {
        ipv4.addresses = [
          {
            address = "192.168.10.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [];
      };
    };

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain output {
            type filter hook output priority 100; policy accept;
          }
          chain input {
            type filter hook input priority filter; policy drop;

            icmp type echo-request limit rate 100/second accept comment "Allow ping"

            udp dport dhcpv6-client accept

            ip6 daddr fe80::/64 udp dport 546 udp sport 547 counter accept comment "WAN DHCPv6"

            icmpv6 type {
              mld-listener-query,
              mld-listener-report,
              mld-listener-done,
              mld-listener-reduction,
              mld2-listener-report,
            } limit rate 1000/second accept comment "Allow MLD"

            ip6 nexthdr icmpv6 icmpv6 type nd-router-solicit counter accept


            icmpv6 type {
              echo-request,
              echo-reply,
              destination-unreachable,
              packet-too-big,
              time-exceeded,
              parameter-problem,
              nd-router-solicit,
              nd-router-advert,
              nd-neighbor-solicit,
              nd-neighbor-advert,
            } limit rate 1000/second accept comment "Allow ICMPv6"

            ip protocol icmp icmp type { echo-request, router-advertisement } accept

            iifname "lo" accept
            iifname "lo" ip saddr != 127.0.0.0/8 drop

            ip saddr 192.168.10.0/24 tcp dport 53 accept;
            ip saddr 192.168.10.0/24 udp dport 53 accept;
            ip saddr 192.168.10.0/24 tcp dport 22 accept;

            ip saddr 10.10.10.0/24 tcp dport 53 accept;
            ip saddr 10.10.10.0/24 udp dport 53 accept;
            ip saddr 10.10.10.0/24 tcp dport 22 accept;


            iifname { "br-lan0", "tailscale0", "wg0" } counter accept

            ip protocol igmp accept comment "accept IGMP"
            ip saddr 224.0.0.0/4 accept
            iifname "pppoe-wan" ct state { established, related }  counter accept comment "Allow established traffic"
            iifname "pppoe-wan" counter drop comment "Drop all other unsolicited from wan"
          }

          chain forward {
            meta oiftype ppp tcp flags syn tcp option maxseg size set 1452
            type filter hook forward priority filter; policy drop;
            icmpv6 type {
              echo-request,
              echo-reply,
              destination-unreachable,
              packet-too-big,
              time-exceeded,
              parameter-problem,
            } limit rate 1000/second accept comment "Allow ICMPv6 Forward"

            # meta l4proto { tcp, udp } flow offload @f

            meta l4proto esp accept comment "Allow IPSec ESP"
            udp dport 500 accept comment "Allow ISAKMP"
            ct status dnat accept comment "Allow port forwards"

            iifname { "br-lan0" } oifname { "pppoe-wan" } counter accept

            iifname { "pppoe-wan" } oifname { "br-lan0" } ct state established,related counter accept
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
    links = {
      # "40-wan0" = {
      #   linkConfig.Name = "wan0";
      #   matchConfig.MACAddress = "";
      # };
      "40-lan0" = {
        linkConfig.Name = "lan0";
        matchConfig.MACAddress = "00:24:81:7d:05:c9";
      };
      "40-lan1" = {
        linkConfig.Name = "lan1";
        matchConfig.MACAddress = "00:24:81:7d:05:c8";
      };
      "40-lan2" = {
        linkConfig.Name = "lan2";
        matchConfig.MACAddress = "00:24:81:7d:05:cb";
      };
      "40-lan3" = {
        linkConfig.Name = "lan3";
        matchConfig.MACAddress = "00:24:81:7d:05:ca";
      };
    };
    netdevs = {
      # br-lan0 = {
      #   netdevConfig = {
      #     Name = "br-lan0";
      #     Kind = "bridge";
      #   };
      # };

      wg0 = {
        netdevConfig = {
          Name = "wg0";
          Kind = "wireguard";
        };
      };
    };
    networks = {
      "40-pppoe-wan" = {
        matchConfig = {
          Name = "pppoe-wan";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };

        networkConfig = {
          DNS = "127.0.0.1";

          IPv6AcceptRA = true;
          DHCP = "ipv6";

          IPForward = "yes";

          IPv6PrivacyExtensions = "kernel";
          IPv6DuplicateAddressDetection = 1;

          KeepConfiguration = "static";
        };

        dhcpV6Config = {
          UseDNS = false;
          UseNTP = false;

          WithoutRA = "solicit";

          PrefixDelegationHint = "::/56";
        };
        cakeConfig = {
          OverheadBytes = 65;
          Bandwidth = "40M";
          NAT = "yes";
          PriorityQueueingPreset = "diffserv4";
        };
      };
      # "40-lan0" = {
      #   name = "lan0";
      #   DHCP = "no";
      #   bridge = ["br-lan0"];
      #   linkConfig.RequiredForOnline = false;
      # };
      # "40-lan1" = {
      #   name = "lan1";
      #   DHCP = "no";
      #   bridge = ["br-lan0"];
      #   linkConfig.RequiredForOnline = false;
      # };

      # "40-lan2" = {
      #   name = "lan2";
      #   DHCP = "no";
      #   bridge = ["br-lan0"];
      #   linkConfig.RequiredForOnline = false;
      # };
      # "40-lan3" = {
      #   name = "lan3";
      #   DHCP = "no";
      #   bridge = ["br-lan0"];
      #   linkConfig.RequiredForOnline = false;
      # };
      "40-br-lan0" = {
        name = "br-lan0";
        networkConfig = {
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
          DHCPPrefixDelegation = true;
          IPv6AcceptRA = false;
        };

        dhcpPrefixDelegationConfig = {
          UplinkInterface = "pppoe-wan";
          Assign = true;
          Announce = true;
        };
      };
      "40-wg0" = {
        name = "wg0";
        DHCP = "no";
        address = ["10.90.0.1/24"];
        linkConfig.RequiredForOnline = false;
      };
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          plugin rp-pppoe.so ppp0

          ifname pppoe-wan

          user anonymous@t-online.de
          password 12345567

          mtu 1500
          mru 1500

          lcp-echo-interval 15
          lcp-echo-failure 3
          lcp-max-configure 10

          hide-password

          default-asyncmap

          maxfail 0
          holdoff 5

          noauth
          noproxyarp
          noaccomp

          nomultilink
          novj

          defaultroute
          defaultroute6
          persist

          +ipv6 ipv6cp-use-ipaddr
        '';
        autostart = true;
        enable = false;
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

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      port = 5300;
      domain = "lan.net.r505.de";
      domain-needed = true;
      local = ["/lan.net.r505.de/"];
      interface = ["br-lan0"];
      dhcp-range = ["192.168.10.51,192.168.10.249,24h"];
      dhcp-authoritative = true;
      dhcp-option = ["option:dns-server,0.0.0.0"];
      dhcp-host = [
        # "00:24:81:7d:05:c9,10.10.10.80" # futro - lan4
      ];
    };
  };

  services.corerad = {
    enable = true;
    settings = {
      interfaces = [
        {
          name = "pppoe-wan";
          monitor = true;
        }
        {
          name = "br-lan0";
          advertise = true;
          prefix = [{prefix = "::/64";}];
          route = [{prefix = "::/0";}];
        }
      ];
    };
  };

  services.blocky = {
    enable = true;
    settings = {
      upstream.default = [
        "tcp-tls:fdns1.dismail.de:853"
        "https://dns.telekom.de/dns-query"
        "https://dns.digitale-gesellschaft.ch/dns-query"
        "https://dnsforge.de/dns-query"
      ];
      startVerifyUpstream = false;
      blocking = {
        blackLists.default = [
          # "https://adaway.org/hosts.txt"
          "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
        ];
        clientGroupsBlock.default = ["default"];
        whiteLists.default = [
          "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/referral-sites.txt"
          "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/optional-list.txt"
        ];
      };
      caching.maxTime = "30m";
      prometheus.enable = true;
      ports.dns = "0.0.0.0:53";
      ports.http = 4000;
      bootstrapDns = "tcp+udp:1.1.1.1";
      ede.enable = true;
      conditional = {
        rewrite = {
          "ts" = "cama-boa.ts.net";
        };
        mapping = {
          "lan.net.r505.de" = "127.0.0.1:5300";
          "cama-boa.ts.net" = "100.100.100.100";
        };
      };
      customDNS = {
        mapping = {
          "net.r505.de" = "192.168.10.1";
        };
      };
    };
  };
  systemd.services.blocky = {
    requires = [
      "ppp-wait-online.service"
    ];
    after = [
      "ppp-wait-online.service"
    ];
    before = lib.mkForce [];
  };
}
