{
  lib,
  config,
  ...
}: let
  wan = "ppp0";
  lan = "eth1";
in {
  networking = {
    firewall.enable = false;
    nat.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          flowtable f {
            hook ingress priority 0
            devices = { ${wan}, ${lan} }
          }

        # allow from this device
        chain output {
          type filter hook output priority filter
          policy accept
          counter accept
        }
      '';
    };
  };
}
