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
  cfg = config.profiles.internal.desktop;
in
{
  options.profiles.internal.desktop = with types; {
    enable = mkBoolOpt false "Enable Desktop Options";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
  };

}
