{
  lib,
  config,
  pkgs,
  ...
}: let
  notify-brightness = pkgs.writeShellScriptBin "notify-brightness" ''
    getvalue() {
      echo "$(${pkgs.brightnessctl}/bin/brightnessctl g) * 100 / $(${pkgs.brightnessctl}/bin/brightnessctl m)" | bc
    }
    geticon() {
      if [ "$1" -eq 0 ]; then
        echo "notification-display-brightness-off"
      elif [ "$1" -lt 20 ]; then
        echo "notification-display-brightness-low"
      elif [ "$1" -lt 50 ]; then
        echo "notification-display-brightness-medium"
      elif [ "$1" -lt 100 ]; then
        echo "notification-display-brightness-high"
      else
        echo "notification-display-brightness-full"
      fi
    }
    ${pkgs.brightnessctl}/bin/brightnessctl "$@"
    value="$(getvalue)"
    # shellcheck disable=all
    icon="$(geticon $value)"
    ${pkgs.dunst}/bin/dunstify \
      --appname=brightness \
      --urgency=low \
      --timeout=2000 \
      --icon="$icon" \
      --hints=int:value:"$value" \
      --hints=string:x-dunst-stack-tag:brightness \
      "Brightness: $value%"
  '';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemdIntegration = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    plugins = [
      #      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    ];
    extraConfig = lib.mkMerge [
      # (
      #   builtins.concatStringsSep "\n" (
      #     map
      #     (m:
      #       if m.enabled
      #       then ''
      #         monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},${toString m.scale}
      #         ${lib.optionalString (m.workspace != null) "workspace=${m.name},${m.workspace}"}
      #       ''
      #       else ''
      #         monitor=${m.name},disabled
      #       '')
      #     config.monitors
      #   )
      # )

      (
        with config.colorscheme.colors; ''
          exec-once = ${pkgs.gtklock}/bin/gtklock -d


          monitor=DP-2,highres,auto,1.5
          exec-once=${pkgs.xorg.xprop}/bin/xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1.5
          env = GDK_SCALE,1.5
          env = XCURSOR_SIZE,24

          exec-once = ${pkgs.polkit_gnome}/libexec/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland
          exec-once = ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
          exec = ${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill

          exec-once = hyprctl setcursor ${config.gtk.cursorTheme.name} 24

          env = XDG_SESSION_DESKTOP,Hyprland
          env = QT_QPA_PLATFORM,wayland;xcb
          env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
          env = SDL_VIDEODRIVER,wayland
          env = CLUTTER_BACKEND,wayland
          env = GDK_BACKEND,wayland,x11


          # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
          input {
              kb_layout = us-german-umlaut
              kb_options =
              kb_rules =

              follow_mouse = 1

              touchpad {
                  natural_scroll = yes
                  drag_lock = true
              }

              sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          }


          # air13 keyboard
          device:at-translated-set-2-keyboard {
            kb_layout = us-german-umlaut
          }

          general {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              gaps_in = 4
              gaps_out = 10
              border_size = 3
              col.active_border = 0xff${base03}
              col.inactive_border = 0xff${base04}

              layout = dwindle
          }

          misc {
            vrr = 2
            disable_autoreload = true
            disable_splash_rendering = true
          }

          decoration {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              rounding = 2
              blur = yes
              blur_size = 8
              blur_passes = 3
              blur_new_optimizations = on

              drop_shadow = true
              shadow_range = 4
              shadow_render_power = 3
              col.shadow = rgba(1a1a1aee)
          }

          animations {
              enabled = yes

              # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              bezier = myBezier, 0.05, 0.9, 0.1, 1.05

              animation = windows, 1, 7, myBezier
              animation = windowsOut, 1, 7, default, popin 80%
              animation = border, 1, 10, default
              animation = fade, 1, 7, default
              animation = workspaces, 1, 6, default
          }

          dwindle {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
              pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = yes # you probably want this
          }

          master {
              # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
              new_is_master = true
          }

          gestures {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              workspace_swipe = on
          }


          windowrulev2 = float,class:anyrun
          windowrulev2 = center,class:anyrun

          windowrulev2 = workspace 2,class:chromium

          windowrulev2 = nomaxsize,class:^(.*)$

          layerrule = blur,gtk-layer-shell
          layerrule = ignorezero,gtk-layer-shell
          layerrule = blur,anyrun
          layerrule = ignorealpha 0.6,anyrun
          layerrule = blur,notifications
          layerrule = ignorezero,notifications
          layerrule = noanim, ^(selection)$

          $mainMod = SUPER

          bind = $mainMod, Q, exec, ${pkgs.wezterm}/bin/wezterm
          bind = $mainMod, C, killactive,
          bind = $mainMod, M, exit,
          bind = $mainMod, E, exec, ${pkgs.cinnamon.nemo}/bin/nemo
          bind = $mainMod, V, togglefloating,
          bind = $mainMod, F, fullscreen, 0
          bind = $mainMod, R, exec, ${config.programs.anyrun.package}/bin/anyrun
          bind = $mainMod, P, pseudo, # dwindle
          bind = $mainMod, J, togglesplit, # dwindle
          bind = $mainMod, L, exec, ${pkgs.systemd}/bin/loginctl lock-session

          # Move focus with mainMod + arrow keys
          bind = $mainMod, left, movefocus, l
          bind = $mainMod, right, movefocus, r
          bind = $mainMod, up, movefocus, u
          bind = $mainMod, down, movefocus, d

          # Switch workspaces with mainMod + [0-9]
          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10

          # Scroll through existing workspaces with mainMod + scroll
          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1

          # Media Keys
          bind = ,XF86MonBrightnessUp, exec,${notify-brightness}/bin/notify-brightness s +5%
          bind = ,XF86MonBrightnessDown, exec,${notify-brightness}/bin/notify-brightness s 5%-

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow

          # lid switch
          bindl=,switch:on:Lid Switch,exec,exec, sleep 1 && hyprctl dispatch dpms off
          bindl=,switch:off:Lid Switch,exec,exec, hyprctl dispatch dpms on

        ''
      )
    ];
  };
}
