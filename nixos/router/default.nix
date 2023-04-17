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
        useDHCP = true;
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
      enable = lib.mkForce false;
      allowPing = true;
    };
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
           # enable flow offloading for better throughput
           # flowtable f {
           #   hook ingress priority 0;
           #   devices = { lan, ppp0 };
           # }

           chain output {
             type filter hook output priority 100; policy accept;
           }

           chain input {
             type filter hook input priority filter; policy accept;

             # Allow trusted networks to access the router
             iifname {
               "lan",
             } counter accept


             # Allow returning traffic from wan and drop everthing else
             iifname "ppp0" ct state { established, related } counter accept
           }
           chain forward {
             type filter hook forward priority filter; policy accept;

             # enable flow offloading for better throughput
             # ip protocol { tcp, udp } flow offload @f

             # Allow trusted network WAN access
             iifname {
                 "lan",
             } oifname {
                 "ppp0",
             } counter accept comment "Allow trusted LAN to WAN"

             # Allow established WAN to return
             iifname {
                 "ppp0",
             } oifname {
                 "lan",
             } ct state established,related counter accept comment "Allow established back to LANs"
           }
         }
         table ip nat {
           chain prerouting {
             type nat hook output priority filter; policy accept;
           }

           # Setup NAT masquerading on the ppp0 interface
           chain postrouting {
             type nat hook postrouting priority filter; policy accept;
             oifname "ppp0" masquerade
           }
         }
      '';
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          plugin pppoe.so
          ifname ppp0
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
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online -i telekom";
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
          name = "lan";
          advertise = true;
          prefix = [{prefix = "::/64";}];
          route = [{prefix = "::/0";}];
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
