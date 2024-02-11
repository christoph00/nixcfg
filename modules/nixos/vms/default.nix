{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.vms;
in {
  imports = [
    inputs.microvm.nixosModules.host
  ];
  options.chr.vms = with types; {
    enable = mkservicesBoolOpt false "Enable VMs.";
  };

  config = mkIf cfg.enable {
    systemd.network = {
      enable = true;
      networks."10-net0" = {
        matchConfig.Name = "net0";
        networkConfig.DHCP = "yes";
      };
    };
    environment.persistence."${cfg.stateDir}" = {
      hideMounts = true;
      directories = [
        "/var/lib/microvms"
      ];
    };
  };
}
