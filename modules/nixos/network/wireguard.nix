{
  config,
  lib,
  ...
}:

with lib;
with lib.internal;

let
  cfg = config.internal.vpn;
  meta = config.internal;
in
{
  options.internal.vpn.enable = mkBoolOpt (meta.hasRole "vpn") "Enable Wireguard VPN Config";

  config = mkIf cfg.enable {

    age.secrets.wg-key.file = ../../../secrets/wg-${meta.thisHost}-key;

    networking.wireguard.interfaces.wg0 = mkIf (meta.currentHost.net.vpn != null) {
      ips = [ "${meta.currentHost.net.vpn}/24" ];
      listenPort = 51820;
      privateKeyFile = "${config.age.secrets.wg-key.path}";

      peers = filter (p: p != null) (
        mapAttrsToList (
          name: host:
          if name == meta.currentHost then
            null
          else
            {
              publicKey = host.wgPubkey;
              allowedIPs =
                if host.zone == "oracle" then
                  [
                    meta.subnets.oracle
                    host.net.vpn
                  ]
                else if host.zone == "home" then
                  [
                    meta.subnets.home
                    host.net.vpn
                  ]
                else
                  [ host.net.vpn ];
              endpoint = mkIf (host.net.wan != "dynamic" && host.net.wan != null) "${host.net.wan}:51820";
              persistentKeepalive = mkDefault 25;
            }
        ) meta.hosts
      );
    };

  };
}
