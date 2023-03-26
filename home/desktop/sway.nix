{
  pkgs,
  inputs,
  lib,
  ...
}: let
  modifier = lib.mkDefault "Mod4";
in {
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    xwayland = true;
    config = {
      modifier = modifier;
      terminal = "${pkgs.foot}/bin/foot";
      menu = "${pkgs.rofi}/bin/rofi -show drun -modi drun";
      gaps = {
        inner = 2;
        outer = 2;
      };
      window.border = 4;
      window.titlebar = true;
      floating.modifier = modifier;

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
      bars = [
        # {
        #   "command" = "${inputs.ironbar.packages.x86_64-linux.default}/bin/ironbar";
        # }
      ];
      keybindings = {
        "${modifier}+Shift+q" = "kill";

        "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 20";
        "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 20";
      };
    };
  };
}
