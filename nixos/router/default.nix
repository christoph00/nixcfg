# https://github.com/vkleen/machines
{
  pkgs,
  lib,
  config,
  ...
}: let
  lanIF = "enp1s0";
  wanIF = "enp0s18u1u3c2";

  nftRuleset = let
    globalTcpPorts =
      lib.lists.map builtins.toString config.networking.firewall.allowedTCPPorts
      ++ lib.lists.map ({
        from,
        to,
      }: "${builtins.toString from}-${builtins.toString to}")
      config.networking.firewall.allowedTCPPortRanges;
    globalUdpPorts =
      lib.lists.map builtins.toString config.networking.firewall.allowedUDPPorts
      ++ lib.lists.map ({
        from,
        to,
      }: "${builtins.toString from}-${builtins.toString to}")
      config.networking.firewall.allowedUDPPortRanges;

    interfaceTcpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedTCPPorts;
    interfaceUdpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedUDPPorts;
  in ''
    define icmp_protos = { ipv6-icmp, icmp, igmp }

    table inet filter {
      chain input {
        type filter hook input priority filter
        policy drop

        iifname { lo } accept
        ct state { related, established} accept

        meta l4proto ipv6-icmp icmpv6 type nd-redirect drop
        meta l4proto $icmp_protos accept

        ${lib.strings.concatStringsSep "\n" (lib.attrsets.mapAttrsToList
      (i: _: ''
        ${lib.strings.optionalString (interfaceUdpPorts i != [])
          "iifname { ${i} } meta l4proto udp udp dport { ${lib.strings.concatStringsSep "," (interfaceUdpPorts i)} } accept"}
        ${lib.strings.optionalString (interfaceTcpPorts i != [])
          "iifname { ${i} } meta l4proto tcp tcp dport { ${lib.strings.concatStringsSep "," (interfaceTcpPorts i)} } accept"}
      '')
      config.networking.firewall.interfaces)}

        meta l4proto tcp tcp dport { ${lib.strings.concatStringsSep "," globalTcpPorts} } accept
        meta l4proto udp udp dport { ${lib.strings.concatStringsSep "," globalUdpPorts} } accept

        meta l4proto udp ip6 daddr fe80::/64 udp dport 546 accept
      }

      chain forward {
        type filter hook forward priority filter
        policy drop
        iifname { lan } accept
        ct state { related, established } accept

        meta l4proto ipv6-icmp icmpv6 type nd-redirect drop
        meta l4proto $icmp_protos accept
      }
    }

    table inet raw {
      chain rpfilter {
        fib saddr . mark oif != 0 return
        meta nfproto ipv4 meta l4proto udp udp sport 67 udp dport 68 return
        meta nfproto ipv4 meta l4proto udp ip saddr 0.0.0.0 ip daddr 255.255.255.255 udp sport 68 udp dport 67 return
        counter drop
      }
      chain prerouting {
        type filter hook prerouting priority raw
        policy accept
        jump rpfilter
      }
    }
    table ip mss_clamp {
      chain postrouting {
        type filter hook postrouting priority mangle
        policy accept
        oifname { ppp0 } meta l4proto tcp tcp flags & (syn|rst) == syn tcp option maxseg size set rt mtu
      }
    }
    table ip nat {
      chain prerouting {
        type nat hook prerouting priority dstnat
        policy accept

        iifname { lan } meta mark set 0x1
      }
      chain postrouting {
        type nat hook postrouting priority srcnat
        policy accept
      }
    }
  '';
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


  networking = {
    vlans = {
      "telekom" = {
        id = 7;
        interface = wanIF;
      };
      "lan" = {
        id = 10;
        interface = lanIF;
      };
    };
    interfaces = {
      "${lanIF}" = {
        useDHCP = false;
      };
      "${wanIF}" = {
        useDHCP = false;
      };

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
      enable = false;
      allowPing = true;
      interfaces = {
        "lan" = {
          allowedUDPPorts = [53 69];
          allowedTCPPorts = [53 69 22];
        };
      };
    };
    nftables = {
      enable = true;
      ruleset = nftRuleset;
    };
    namespaces.enable = true;
  };

  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          plugin pppoe.so wan
          ifname telekom
          nic-eno1
          lcp-echo-failure 5
          lcp-echo-interval 1
          maxfail 0
          mru 1492
          mtu 1492
          persist
          user anonymous@t-online.de
          password 123456789
          noauth
          defaultroute
          +ipv6
          up_sdnotify
          defaultroute6
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
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online -i ppp0";
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

   services.corerad = {
    enable = true;
    settings = {
      interfaces = [
        { name = "lan";
          advertise = true;
          prefix = [{ prefix = "::/64"; }];
          route = [{ prefix = "::/0"; }];
        }
      ];
    };
  };


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
