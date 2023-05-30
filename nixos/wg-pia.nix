{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.network = {
    netdevs = {
      "99-wg-pia" = {
        netdevConfig = {
          Name = "wg-pia";
          Kind = "wireguard";
          Description = "WireGuard tunnel wg-pia";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wg-pia-key.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "HuwmjIO54wtTa5ZW0q84bCC1mPOvnggNYGTE1oDcLRY=";
              AllowedIPs = "0.0.0.0/0";
              Endpoint = "212.102.57.80:1337";
              PersistentKeepalive = 25;
            };
          }
        ];
      };
    };
    networks."99-wg-pia" = {
      name = "wg-pia";
      address = ["10.15.200.49/32"];
    };
  };
}
