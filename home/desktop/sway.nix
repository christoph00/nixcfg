{
  pkgs,
  lib,
  ...
}: let
  mod = lib.mkDefault "Mod4";
in {
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = mod;
      terminal = "${pkgs.foot}/bin/foot";
      menu = "${pkgs.rofi}/bin/rofi -show drun -modi drun";
      gaps = {
        inner = 2;
        outer = 2;
      };
      window.border = 4;
      window.titlebar = false;
      floating.modifier = mod;

      input = {
        "type:touchpad" = {
          tap = "enabled";
          dwt = "enabled";
          scroll_method = "two_finger";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
        };
        "type:keyboard" = {
          xkb_layout = "us";
        };
      };

      window = {
        commands = [
          {
            criteria.window_role = "pop-up";
            command = "floating enable";
          }
        ];
      };
      bars = [];
      keybindings = {
        # Screen brightness controls
        "--locked XF86MonBrightnessUp" = "exec ${pkgs.light} -A 10";
        "--locked XF86MonBrightnessDown" = "exec ${pkgs.light} -U 10";
      };
    };
    extraConfig = ''
      bindgesture swipe:3:left workspace next
      bindgesture swipe:3:right workspace prev
    '';
  };
}
