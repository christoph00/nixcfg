{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.internal.desktop;
in
{
  options.internal.desktop = with types; {
    enable = mkBoolOpt false "Enable Gaming Options";
  };

}
