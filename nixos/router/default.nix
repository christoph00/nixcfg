{
  pkgs,
  lib,
  config,
  ...
}: {
  services.pppd = {
    enable = true;
    peers = {
      telekom = {
        config = ''
          plugin pppoe.so
          ifname ppp0
          nic-eno1
          lcp-echo-failure 5
          lcp-echo-interval 1
          maxfail 1
          mru 1492
          mtu 1492
          user anonymous@t-online.de
          password 123456789
          defaultroute
        '';
        autostart = false;
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
}
