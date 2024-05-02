{
  options,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.desktop.cosmic;
in
{
  options.chr.desktop.cosmic = with types; {
    enable = mkBoolOpt false "Whether or not enable Cosmic Desktop.";
  };

  config = mkIf cfg.enable { };
}
