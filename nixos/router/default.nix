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
        table inet filter {
          chain output {
            type filter hook output priority 100; policy accept;
          }
          chain input {
            type filter hook input priority filter; policy drop;

            icmp type echo-request accept comment "Allow ping"

            ip6 saddr fc00::/6 ip6 daddr fc00::/6 udp dport 546 accept comment "Allow DHCPv6"
            ip6 saddr fe80::/10 icmpv6 type {
              mld-listener-query,
              mld-listener-report,
              mld-listener-done,
              mld-listener-reduction,
              mld2-listener-report,
            } accept comment "Allow MLD"

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

            iifname "lo" accept
            iifname "lo" ip saddr != 127.0.0.0/8 drop

            ip saddr 10.0.0.0/8 tcp dport 53 accept;
            ip saddr 10.0.0.0/8 udp dport 53 accept;
            ip saddr 10.0.0.0/8 tcp dport 22 accept;


            iifname "lan" counter accept
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

            #meta l4proto { tcp, udp } flow offload @f

            meta l4proto esp accept comment "Allow IPSec ESP"
            udp dport 500 accept comment "Allow ISAKMP"
            ct status dnat accept comment "Allow port forwards"

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

        table ip6 filter {
          chain input {
            type filter hook input priority 0; policy drop;
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
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
        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
          DNS = "127.0.0.1";
          DHCP = "ipv6";
          IPv6DuplicateAddressDetection = 1;
          KeepConfiguration = "static";
          DefaultRouteOnDevice = true;
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
        };
      };
      "40-lan" = {
        matchConfig.Name = "lan";
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          # IPv6DuplicateAddressDetection = 1;
          # IPv6AcceptRA = true;
          # DHCPPrefixDelegation = true;
          # IPv6SendRA = true;
        };
        dhcpServerConfig = {
          EmitRouter = true;
          EmitDNS = true;
          PoolOffset = 50;
          PoolSize = 120;
          DNS = "_server_address";
        };

        dhcpPrefixDelegationConfig = {
          SubnetId = "10";
          UplinkInterface = "pppoe-wan";
            Assign = true;
            Announce = true;
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
      ports.dns = "0.0.0.0:53";
      ports.http = 4000;
      bootstrapDns = "tcp+udp:1.1.1.1";
      ede.enable = true;
      # conditional = {
      #   mapping = {
      #     "lan.net.r505.de" = "127.0.0.1:5300";
      #   };
      # };
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
