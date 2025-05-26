{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.network.router;
in
{
  config = mkIf cfg.enable {
    systemd.network = {
      networks."10-internal" = {
        name = cfg.internalInterface;
        DHCP = "no";
        bridge = [ "lan" ];
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

    services.avahi = {
      enable = true;
      reflector = true;
      allowInterfaces = [
        "lan"
        "ts0"
        "wt0"
      ];
    };

    services.ntpd-rs = enabled;
  };

}
