{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.vms;
in
{
  options.chr.vms = with types; {
    enable = mkBoolOpt false "Enable VMs.";
  };

  imports = [
    inputs.microvm.nixosModules.host
    inputs.microvm.nixosModules.microvm
  ];

  config = {
    microvm.host.enable = lib.mkForce cfg.enable;
    microvm.guest.enable = lib.mkForce config.chr.isMicroVM;

    systemd.network = mkIf cfg.enable {
      enable = true;
      netdevs.internet.netdevConfig = {
        Kind = "bridge";
        Name = "internet";
      };

      networks."5-internet" = {
        matchConfig.Name = "internet";
        networkConfig.DHCP = "yes";
      };

      networks.microvm-internet = {
        matchConfig.Name = "vm-*";
        networkConfig.Bridge = "internet";
      };

      networks.tap-internet = {
        matchConfig.Name = "tap-internet";
        networkConfig.Bridge = "internet";
      };
    };
    environment.persistence."${config.chr.system.persist.stateDir}" = mkIf cfg.enable {
      hideMounts = true;
      directories = [ "/var/lib/microvms" ];
    };
  };
}
