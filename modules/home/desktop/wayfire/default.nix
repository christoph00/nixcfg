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
  cfg = config.profiles.internal.desktop.wayfire;
  
in
{
  options.profiles.internal.desktop.wayfire = with types; {
    enable = mkBoolOpt config.profiles.interal.desktop.enable "Enable Wayfire Options";
  };

  config = mkIf cfg.enable {

wayland.windowManager.wayfire = {
  enable = true;
  setting = {

    plugins =        [
              { plugin = "move"; settings.activate = "<super> BTN_LEFT"; }
              { plugin = "place"; settings.mode = "cascade"; }
              { package = pkgs.wayfirePlugins.firedecor;
                plugin = "firedecor";
                settings = {
                  layout = "-";
                  border_size = 8;
                  active_border = [ 0.121569 0.121569 0.156863 1.000000 ];
                  inactive_border = [ 0.121569 0.121569 0.156863 1.000000 ];
                };
              }
            ];
    

  };

};

  };

}
