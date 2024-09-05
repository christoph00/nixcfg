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
    mkIf
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.internal.apps.moonlight;
in
{
  options.internal.apps.moonlight = with types; {
    enable = mkBoolOpt config.internal.desktop.enable "Enable App Moonlight";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.moonlight-qt ];
  };

}
