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
    enable = mkBoolOpt config.profiles.internal.desktop.enable "Enable Wayfire Options";
  };

  config = mkIf cfg.enable {

wayland.windowManager.wayfire = {
  enable = true;
  setting = {

    close_top_view = "<super> KEY_Q | <alt> KEY_F4";

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
