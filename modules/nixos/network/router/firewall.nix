{
  config,
  lib,
  flake,
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkOpt mkForce;
  cfg = config.network.router;
in
{
  config = mkIf cfg.enable {
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    networking = {
      nftables.enable = true;
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
  };
}
