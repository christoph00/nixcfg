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

    home.packages = [
      pkgs.anyrun
      pkgs.xwayland
      pkgs.wayfirePlugins.wcm
    ];

    profiles.internal.desktop.wayfire = {
      enable = true;
      settings = {
        close_top_view = "<super> KEY_Q | <alt> KEY_F4";
        # Workspaces arranged into a grid: 3 × 3.
        vwidth = 3;
        vheight = 3;
        max_render_time = 7;
        preferred_decoration_mode = "client";
        xwayland = true;
        background-color = "#000000";

        plugins = [
          {
            plugin = "command";
            settings = {
              command_menu = "${pkgs.anyrun}/bin/anyrun";
              binding_menu = "<super> KEY_R";

              command_terminal = "${pkgs.foot}/bin/footclient";
              binding_terminal = "<super> KEY_RETURN";

              command_light_up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
              command_light_down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
              command_volume_up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
              command_volume_down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

              repeatable_binding_light_down = "KEY_BRIGHTNESSDOWN";
              repeatable_binding_light_up = "KEY_BRIGHTNESSUP";
              repeatable_binding_volume_down = "KEY_VOLUMEDOWN";
              repeatable_binding_volume_up = "KEY_VOLUMEUP";
            };

          }
          {
            plugin = "idle";
            settings = {
              dpms_timeout = 4000;
            };
          }
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
            plugin = "workarounds";
            settings.app_id_mode = "gtk-shell";
          }
          {
            plugin = "ipc";
          }
          { plugin = "ipc-rules"; }
          {
            plugin = "fast-switcher";
            settings.activate = "<super> KEY_TAB";
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

          { plugin = "foreign-toplevel"; }
          { plugin = "gtk-shell"; }
          { plugin = "xdg-activation"; }
          { plugin = "session-lock"; }
          { plugin = "input-method-v1"; }
          {
            plugin = "autostart";
            settings = {
              autostart_wf_shell = false;
              activate = ''${pkgs.writeShellScript "import-user-env-to-dbus-systemd" ''
                if [ -d "/etc/profiles/per-user/$USER/etc/profile.d" ]; then
                  . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
                fi
                ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
                  XDG_CONFIG_HOME XDG_DATA_HOME XDG_BACKEND DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
              ''}'';

              start_session = "systemctl --user start wayfire-session.target";
              gammastep = "${pkgs.gammastep}/bin/gammastep -m wayland  -l 52.373920:9.735603";
              mako = "${pkgs.mako}/bin/mako";

              desktop-portal = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
              desktop-portal-wlr = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";

              configure_gtk =
                let
                  schema = pkgs.gsettings-desktop-schemas;
                  datadir = "${schema}/share/gsettings-schemas/${schema.name}";
                in
                ''${pkgs.writeShellScript "configure-gtk" ''
                  export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
                    gnome_schema=org.gnome.desktop.interface
                    ${pkgs.glib}/bin/gsettings set $gnome_schema gtk-theme '${config.gtk.theme.name}'
                    ${pkgs.glib}/bin/gsettings set $gnome_schema icon-theme '${config.gtk.iconTheme.name}'
                    ${pkgs.glib}/bin/gsettings set $gnome_schema cursor-theme '${config.gtk.cursorTheme.name}'
                ''}'';

              waybar = "${config.programs.waybar.package}/bin/waybar";
              #wf_panel = "${wf}/bin/wf-panel";
              #ironbar = "${pkgs.ironbar}/bin/ironbar";
              #background = "${wf}/bin/wf-background";
              #env = "systemctl --user import-environment";
            };
          }
          { plugin = "blur"; }
          {
            plugin = "expo";
            settings.toggle = "<super> KEY_E";
          }
          { plugin = "wayfire-shell"; }
          {
            plugin = "wf-shell";
            package = pkgs.wayfirePlugins.wf-shell;
          }
          { plugin = "alpha"; }
          { plugin = "animate"; }
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
