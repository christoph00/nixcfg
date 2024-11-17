{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.router;

in

{

  options.internal.services.router = {
    enable = mkBoolOpt config.internal.isRouter "Enable Router.";
    internalInterface = mkOption {
      type = types.str;
      default = "eth1";
      description = "The internal interface to use.";
    };
    externalInterface = mkOption {
      type = types.str;
      default = "eth2";
      description = "The external interface to use.";
    };
  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/private/technitium-dns-server" ];
    services.technitium-dns-server = {
      enable = true;
      openFirewall = true;
      firewallUDPPorts = [
        53
        67
      ];
    };

    networking = {
      nftables.enable = true;

      firewall.allowedTCPPorts = [ 53 ];

      firewall.extraInputRules = ''
        ip protocol icmp icmp type {
                destination-unreachable,
                router-advertisement,
                time-exceeded,
                parameter-problem
              } accept

        counter drop
      '';

      firewall.filterForward = true;

      firewall.interfaces.dtag-ppp.allowedUDPPorts = [ 546 ];
      firewall.extraForwardRules = ''
        iifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu
        oifname dtag-ppp tcp flags syn tcp option maxseg size set rt mtu
      '';

      nftables.tables.shaping = {
        enable = true;
        family = "inet";
        name = "shaping";
        content = ''
          chain postrouting {
              type route hook output priority -150; policy accept;
              ip daddr != 192.168.0.0/16 jump wan                               # non LAN traffic: chain wan
              ip daddr 192.168.0.0/16 meta length 1-64 meta priority set 1:11   # small packets in LAN: priority
            }
            chain wan {
              tcp dport 22 meta priority set 1:21 return                       # SSH traffic -> Internet: priority
              meta length 1-64 meta priority set 1:21 return                   # small packets -> Internet: priority
              meta priority set 1:20 counter                                   # default -> Internet: normal
            }
        '';
      };

      nat = {
        enable = true;
        internalInterfaces = [ cfg.internalInterface ];
        externalInterface = cfg.externalInterface;
      };

    };

    systemd.network = {
      links."10-eth2" = {
        matchConfig.Path = "pci-0000:01:00.0";
        linkConfig.Name = "eth1";
      };
      links."10-eth1" = {
        matchConfig.Path = "pci-0000:02:00.1";
        linkConfig.Name = "eth2";
      };

      networks."10-eth1" = {
        name = "eth1";
        DHCP = "no";
        addresses = [ { Address = "10.10.1.2/24"; } ];
        vlan = [ "dtag-wan" ];
        linkConfig.MTUBytes = toString 1600;
      };

      networks."10-eth2" = {
        name = "eth2";
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
          IPv6AcceptRA = "no";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
          DHCPServer = "no";
          DNS = [
            "192.168.2.2"
            # "fe80::1"
          ];
        };
        addresses = [
          { Address = "192.168.2.2/24"; }
          #{ Address = "fe80::1/64"; }
        ];
        ipv6SendRAConfig = { };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "dtag-ppp";
          SubnetId = "0x01";
          Announce = "yes";
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

  };

}
