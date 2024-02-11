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
  ];

  config = mkMerge [
    {microvm.host.enable = cfg.enable;}
    (mkIf cfg.enable)
    {
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
    }
  ];
}
