{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.vms;
in {
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
      networks."10-net0" = {
        matchConfig.Name = "net0";
        networkConfig.DHCP = "yes";
      };
    };
    environment.persistence."${config.chr.system.persist.stateDir}" = mkIf cfg.enable {
      hideMounts = true;
      directories = [
        "/var/lib/microvms"
      ];
    };
  };
}
