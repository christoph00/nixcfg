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
  cfg = config.profiles.internal.gaming;
in
{
  options.profiles.internal.gaming = with types; {
    enable = mkBoolOpt false "Enable Gaming Options";
  };

}
