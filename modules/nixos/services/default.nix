{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services;
in {
  options.chr.services = with types; {
    smart-home.enable = mkBoolOpt false "Enable Smart Home Services.";
  };
}
