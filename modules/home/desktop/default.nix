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

  wf = config.profiles.internal.desktop.wayfire.finalPackage;

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
        # Workspaces arranged into a grid: 3 × 3.
        vwidth = 3;
        vheight = 3;

        # Prefer client-side decoration or server-side decoration
        preferred_decoration_mode = "client";
        plugins = [
          {
            plugin = "input";
            settings.xkb_layout = "de";
          }
          {
            plugin = "move";
            settings.activate = "<super> BTN_LEFT";
          }
          {
            plugin = "place";
            settings.mode = "cascade";
          }
          {
            plugin = "resize";
            settings.activate = "<super> BTN_RIGHT";
          }
          {
            plugin = "grid";
            settings = {
              slot_l = "<super> KEY_LEFT";
              slot_c = "<super> KEY_UP";
              slot_r = "<super> KEY_RIGHT";

              restore = "<super> KEY_DOWN";
            };
          }
          {
            plugin = "switcher";
            settings.next_view = "<super> KEY_TAB";
          }
          { plugin = "foreign-toplevel"; }
          { plugin = "gtk-shell"; }
          {
            plugin = "autostart";
            settings = {
              dbus = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
              start_session = "systemctl --user start wayfire-session.target";
              wf_panel = "${wf}/bin/wf-panel";
              background = "${wf}/bin/wf-background";
              #env = "systemctl --user import-environment";
            };
          }
          {
            plugin = "wf-shell";
            package = pkgs.wayfirePlugins.wf-shell;
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
