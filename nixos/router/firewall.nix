{
  lib,
  config,
  ...
}: let
  wan = config.networking.nat.externalInterface;
  lan = config.networking.nat.internalInterfaces;
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
      '';
    };
  };
}
