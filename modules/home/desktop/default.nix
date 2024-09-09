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
    profiles.internal.desktop.wayfire = {
      enable = true;
      settings = {
        close_top_view = "<super> KEY_Q | <alt> KEY_F4";
        plugins = [
          {
            plugin = "move";
            settings.activate = "<super> BTN_LEFT";
          }
          {
            plugin = "place";
            settings.mode = "cascade";
          }
          {
            plugin = "autostart";
            settings = {
              env = "systemctl --user import-environment";
            };
          }
          {
            package = pkgs.wayfirePlugins.firedecor;
            plugin = "firedecor";
            settings = {
              layout = "-";
              border_size = 8;
              active_border = [
                0.121569
                0.121569
                0.156863
                1.0
              ];
              inactive_border = [
                0.121569
                0.121569
                0.156863
                1.0
              ];
            };
          }
        ];

      };
    };
  };

}
