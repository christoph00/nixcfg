{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.vms.openwrt;
in {
  options.chr.vms.openwrt = with types; {
    enable = mkBoolOpt' false;
  };

  config =
    mkIf cfg.enable {
    };
}
