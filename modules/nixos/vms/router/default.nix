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
  cfg = config.chr.vms.router;
in
{
  options.chr.vms.router = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    microvm.vms.vm-router = {
      flake = inputs.self;
      updateFlake = "github:christoph00/nixcfg";
    };
  };
}
