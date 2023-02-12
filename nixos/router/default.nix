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
    "net.ipv4.ip_dynaddr" = "1";
    #    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  systemd.network = {
    networks.wan = {
      dhcpV4Config = {
        UseDNS = false;
        UseDomains = false;
      };
      dhcpV6Config = {
        PrefixDelegationHint = "::/56";
        UseDNS = false;
      };
      ipv6AcceptRAConfig = {
        UseDNS = false;
        UseDomains = false;
      };
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          plugin pppoe.so
          eth0.7
          ifname ppp0
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
}
