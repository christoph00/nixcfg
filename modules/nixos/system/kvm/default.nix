{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.kvm;
in {
  options.chr.system.kvm = with types; {
    enable = mkBoolOpt false "Whether or not to configure kvm.";
    externalInterface = mkOption {
      type = types.str;
      default = "ens5";
      description = "External network interface to use for kvm.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.qemu_kvm
      pkgs.qemu-utils
      pkgs.firecracker
      pkgs.firectl
    ];
  };
}
