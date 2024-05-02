{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.vms.smarthome;
in
{
  options.chr.vms.smarthome = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    microvm.vms.vm-smarthome = {
      flake = inputs.self;
      updateFlake = "github:christoph00/nixcfg";
    };
  };
}
