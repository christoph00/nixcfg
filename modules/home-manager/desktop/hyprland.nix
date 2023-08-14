{
  osConfig,
  pkgs,
  lib,
  inputs',
  config,
  ...
}: let
  pointer = config.gtk.cursorTheme;
  monitors = osConfig.nos.hw.monitors;
  primaryMonitor = builtins.head (lib.filter (monitor: monitor.isPrimary) monitors);
in {
  config = lib.mkIf (osConfig.nos.desktop.wm == "Hyprland") {
    wayland.windowManager.hyprland = with config.colorscheme; {
      enable = true;
      systemdIntegration = true;
      xwayland = {
        enable = true;
        hidpi = primaryMonitor.scale > 1;
      };
      package = inputs'.hyprland.packages.default.override {
        enableXWayland = true;
        nvidiaPatches = false;
      };
      plugins = [inputs'.hy3.packages.hy3];

      settings = {
        "$MOD" = "SUPER";

        monitor = map (monitor:
          if monitor.enabled
          then "${monitor.name},${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate},${toString monitor.x}x${toString monitor.y},${toString monitor.scale}"
          else "${monitor.name},disable")
        monitors;

        exec-once = [
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
          #"xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 24c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2"
        ];

        env = [
          "GDK_SCALE, ${toString primaryMonitor.scale}"
          "XCURSOR_SIZE, ${toString pointer.size}"
          "GDK_BACKEND,wayland,x11"
          "NIXOS_OZONE_WL, 1"
          # "WLR_DRM_NO_MODIFIERS,1"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "SDL_VIDEODRIVER,x11"
        ];

        xwayland = {
          force_zero_scaling = true;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_forever = true;
        };

        input = {
          kb_layout = "us-german-umlaut";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = "no";
            drag_lock = true;
          };
        };

        general = {
          sensitivity = 0.8;
          gaps_in = 6;
          gaps_out = 11;
          border_size = 3;
          "col.active_border" = "0xff${colors.base0F}";
          apply_sens_to_raw = 0;
        };

        decoration = {
          rounding = 7;
          multisample_edges = true;
          drop_shadow = "yes";
          shadow_range = 14;
          shadow_render_power = 3;
          "col.shadow" = "rgba(292c3cee)";
        };

        misc = {
          vrr = 1;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;

          # window swallowing
          enable_swallow = true; # hide windows that spawn other windows
          swallow_regex = "foot|thunar|nemo";

          # dpms
          mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
          key_press_enables_dpms = true; # enable dpms on keyboard action
          disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
        };

        animations = {
          enabled = true; # we want animations, half the reason why we're on Hyprland innit

          bezier = [
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
            "overshot, 0.4,0.8,0.2,1.2"
          ];

          animation = [
            "windows, 1, 4, overshot, slide"
            "windowsOut, 1, 4, smoothOut, slide"
            "border,1,10,default"

            "fade, 1, 10, smoothIn"
            "fadeDim, 1, 10, smoothIn"
            "workspaces,1,4,overshot,slidevert"
          ];
        };

        dwindle = {
          pseudotile = false;
          preserve_split = "yes";
          no_gaps_when_only = false;
        };

        bind = [
          "$MOD, Q, exec, ${pkgs.wezterm}/bin/wezterm"
          "$MOD, R, exec, ${config.programs.anyrun.package}/bin/anyrun"
          # window operators
          "$MOD,C,killactive," # kill focused window
          "$MOD,T,togglegroup," # group focused window
          "$MODSHIFT,G,changegroupactive," # switch within the active group
          "$MOD,V,togglefloating," # toggle floating for the focused window
          "$MOD,P,pseudo," # pseudotile focused window
          "$MOD,F,fullscreen," # fullscreen focused window
        ];

        bindm = [
          "$MOD,mouse:272,movewindow"
          "$MOD,mouse:273,resizewindow"
        ];

        binde = [
          # volume controls
          ",XF86AudioRaiseVolume, exec, volume -i 5"
          ",XF86AudioLowerVolume, exec, volume -d 5"
          ",XF86AudioMute, exec, volume -t"

          # brightness controls
          ",XF86MonBrightnessUp,exec,brightness set +5%"
          ",XF86MonBrightnessDown,exec,brightness set 5%-"
        ];

        windowrulev2 = [
          "float,class:anyrun"
          "center,class:anyrun"

          "noshadow, floating:0"

          "float, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"

          "float,class:pavucontrol"
          "float,title:^(Volume Control)$"
          "size 800 600,title:^(Volume Control)$"
          "move 75 44%,title:^(Volume Control)$"
          "float, class:^(imv)$"
        ];

        layerrule = [
          "blur, ^(gtk-layer-shell|anyrun)$"
          "ignorezero, ^(gtk-layer-shell|anyrun)$"
        ];
      };
      extraConfig = ''
        # a submap for resizing windows
        bind = $MOD, S, submap, resize # enter resize window to resize the active window

        submap=resize
        binde=,right,resizeactive,10 0
        binde=,left,resizeactive,-10 0
        binde=,up,resizeactive,0 -10
        binde=,down,resizeactive,0 10
        bind=,escape,submap,reset
        submap=reset

        # workspace binds
        # binds * (asterisk) to special workspace
        bind = $MOD, KP_Multiply, togglespecialworkspace
        bind = $MODSHIFT, KP_Multiply, movetoworkspace, special

        # and mod + [shift +] {1..10} to [move to] ws {1..10}
        ${
          builtins.concatStringsSep
          "\n"
          (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 8;
                in
                  builtins.toString (x + 1 - (c * 8));
              in ''
                bind = $MOD, ${ws}, workspace, ${toString (x + 1)}
                bind = $MOD SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
              ''
            )
            8)
        }
      '';
    };
  };
}
