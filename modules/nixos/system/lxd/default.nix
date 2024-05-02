{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.lxd;
in
{
  options.chr.system.lxd = with types; {
    enable = mkBoolOpt false "Whether or not to configure lxd.";
    externalInterface = mkOption {
      type = types.str;
      default = "ens5";
      description = "External network interface to use for lxd.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      lxd = {
        enable = true;
        recommendedSysctlSettings = true;
        ui.enable = true;
      };
      lxc.lxcfs.enable = true;
    };
  };
}
