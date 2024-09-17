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
  cfg = config.profiles.internal.apps.misc;
in
{
  options.profiles.internal.apps.misc = with types; {
    enable = mkBoolOpt config.profiles.internal.desktop.enable "Enable Misc Apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      sushi
      nautilus-open-any-terminal
    ];
  };

}
