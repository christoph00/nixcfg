{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = let
    makoctl = "${pkgs.mako}/bin/makoctl";
    pactl = "${pkgs.pulseaudio}/bin/pactl";
    swayidle = "${pkgs.swayidle}/bin/swayidle";
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
    lock = "${pkgs.gtklock}/bin/gtklock";
    systemctl = "${pkgs.systemd}/bin/systemctl";
    wofi = "${pkgs.wofi}/bin/wofi";
    notifysend = "${pkgs.libnotify}/bin/notify-send";

    #eww = "${config.programs.eww.package}/bin/eww";

    terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";
    #terminal = "${pkgs.wezterm}/bin/wezterm";
    terminal = "${pkgs.foot}/bin/footclient";

    eewScript = pkgs.writeShellScriptBin "eewScript" ''
      function handle {
        if [[ ''${1:0:9} == "workspace" ]]; then #set focused workspace
          hyperctl update 'workspace="''${1:11}"'

        elif [[ ''${1:0:15} == "createworkspace" ]]; then #set Occupied workspace
          num=''${1:17}
          export o"$num"="$num"
          export f"$num"="$num"

        elif [[ ''${1:0:16} == "destroyworkspace" ]]; then #unset unoccupied workspace
          num=''${1:18}
          unset -v o"$num" f"$num"
        fi
      }
      ${pkgs.socat}/bin/socat - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done
    '';

    mkValueString = value: (
      if builtins.isBool value
      then
        (
          if value
          then "true"
          else "false"
        )
      else if (builtins.isFloat value || builtins.isInt value)
      then
        (
          builtins.toString value
        )
      else if builtins.isString value
      then value
      else if
        (
          (builtins.isList value)
          && ((builtins.length value) == 2)
          && ((builtins.isFloat (builtins.elemAt value 0)) || (builtins.isFloat (builtins.elemAt value 0)))
          && ((builtins.isFloat (builtins.elemAt value 1)) || (builtins.isFloat (builtins.elemAt value 1)))
        )
      then
        (
          builtins.toString (builtins.elemAt value 0) + " " + builtins.toString (builtins.elemAt value 1)
        )
      else abort "Unhandled value type ${builtins.typeOf value}"
    );

    concatAttrs = arg: func: (
      assert builtins.isAttrs arg;
        builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList func arg)
    );

    mkHyprlandVariables = arg: (
      concatAttrs arg (
        name: value:
          name
          + (
            if builtins.isAttrs value
            then
              (
                " {\n" + (mkHyprlandVariables value) + "\n}"
              )
            else " = " + mkValueString value
          )
      )
    );

    mkHyprlandBinds = arg: (
      concatAttrs arg (
        name: value: (
          if builtins.isList value
          then
            (
              builtins.concatStringsSep "\n" (builtins.map (x: name + " = " + x) value)
            )
          else
            concatAttrs value (
              name2: value2: name + " = " + name2 + "," + (assert builtins.isString value2; value2)
            )
        )
      )
    );
  in {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemdIntegration = true;
    xwayland = {
      enable = true;
    };
    extraConfig = with config.colorscheme.colors;
      mkHyprlandVariables {
        input = {
          kb_layout = "us";
          #kb_variant = "nodeadkeys";
          follow_mouse = true;
          touchpad = {
            natural_scroll = true;
          };
        };
        general = {
          border_size = 2;
          gaps_in = 4;
          gaps_out = 10;
          "col.active_border" = "0xff${base03}";
          "col.inactive_border" = "0xff${base01}";
          cursor_inactive_timeout = 5;
          layout = "master";
        };
        decoration = {
          rounding = 2;
          multisample_edges = true;
          active_opacity = 0.9;
          inactive_opacity = 0.65;
          fullscreen_opacity = 1.0;
          blur = true;
          blur_size = 6;
          blur_passes = 3;
          blur_new_optimizations = true;
          blur_ignore_opacity = true;
          drop_shadow = false;
          shadow_range = 12;
          shadow_offset = "3 3";
          "col.shadow" = "0x44000000";
          "col.shadow_inactive" = "0x66000000";
        };
        animations = {
          enabled = true;
        };
        master = {
          new_is_master = false;
          new_on_top = false;
          no_gaps_when_only = true;
        };
        gestures = {
          workspace_swipe = true;
        };
      }
      + "\n"
      + mkHyprlandBinds {
        bezier = {
          linear = "0,0,1,1";
        };
      }
      + "\n"
      + mkHyprlandBinds {
        monitor = {
          eDP-1 = "preferred,0x0,1";
        };
        workspace = {
          eDP-1 = "1";
        };
        animation = {
          windows = "1,1,linear,slide";
          windowsIn = "1,1,linear,popin";
          windowsOut = "1,1,linear,popin";
          fade = "1,3,linear";
          workspaces = "1,1,linear,slide";
          specialWorkspace = "1,2,linear,slidevert";
        };
        wsbind = {
          # 1-10 ws to screen 1
          "1" = "eDP-1";
          "2" = "eDP-1";
          "3" = "eDP-1";
          "4" = "eDP-1";
          "5" = "eDP-1";
          "6" = "eDP-1";
          "7" = "eDP-1";
          "8" = "eDP-1";
          "9" = "eDP-1";
          "10" = "eDP-1";
        };
        bind = {
          ## audio control
          ",XF86AudioRaiseVolume" = "exec,pamixer -i 1";
          ",XF86AudioLowerVolume" = "exec,pamixer -d 1";
          ",XF86AudioMute" = "exec,pamixer -t";
          #  ",XF86AudioPlay" = "exec,playerctl play-pause";
          #  ",XF86AudioNext" = "exec,playerctl next";
          #  ",XF86AudioPrev" = "exec,playerctl previous";
          ## brightness control
          ",XF86MonBrightnessUp" = "exec,${pkgs.brightnessctl}/bin/brightnessctl s +10%";
          ",XF86MonBrightnessDown" = "exec,${pkgs.brightnessctl}/bin/brightnessctl s 10%-";
          ## display control
          ",XF86Display" = "exec,${lock}";
          ## killing application
          ",XF86RFKill" = "killactive,";
          # STARTERS
          "SUPER,Return" = "exec,${terminal}";
          #  "SUPER,B" = "exec,${chromium}";
          #"SUPER,d" = "exec,";
          #"SUPER,space" = "exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";
          "SUPER,space" = "exec,${pkgs.fuzzel}/bin/fuzzel";
          "SUPER,k" = "togglespecialworkspace,";
          "SUPER,o" = "toggleopaque,";
          # SHORTCUT KEYS
          "SUPER,C" = "killactive,";
          "SUPER,F" = "fullscreen,";
          "SUPER,V" = "togglefloating,e";
          "SUPER,L" = "exec,${lock}";

          # switch between workspaces directly
          "SUPER, 1" = "workspace, 1";
          "SUPER, 2" = "workspace, 2";
          "SUPER, 3" = "workspace, 3";
          "SUPER, 4" = "workspace, 4";
          "SUPER, 5" = "workspace, 5";
          "SUPER, 6" = "workspace, 6";
          "SUPER, 7" = "workspace, 7";
          "SUPER, 8" = "workspace, 8";
          "SUPER, 9" = "workspace, 9";
          "SUPER, 0" = "workspace, 10";

          # move containers between workspaces directly
          "SUPER SHIFT, 1" = "movetoworkspace, 1";
          "SUPER SHIFT, 2" = "movetoworkspace, 2";
          "SUPER SHIFT, 3" = "movetoworkspace, 3";
          "SUPER SHIFT, 4" = "movetoworkspace, 4";
          "SUPER SHIFT, 5" = "movetoworkspace, 5";
          "SUPER SHIFT, 6" = "movetoworkspace, 6";
          "SUPER SHIFT, 7" = "movetoworkspace, 7";
          "SUPER SHIFT, 8" = "movetoworkspace, 8";
          "SUPER SHIFT, 9" = "movetoworkspace, 9";
          "SUPER SHIFT, 0" = "movetoworkspace, 10";
          "SUPER,mouse:274" = "killactive";
        };
        bindm = {
          "SUPER,mouse:272" = "movewindow";
          "SUPER,mouse:273" = "resizewindow";
        };
        bindl = {
          ",switch:Lid Switch" = "exec,${lock} -fF && ${systemctl} hybrid-sleep";
        };
        windowrulev2 = [
          "float,class:Wofi"
          "float,class:fuzzel"
          "tile,class:PPSSPPSDL"
          # "noborder,class:Wofi"
          "center,class:Wofi"
          "center,class:fuzzel"
          # no transparency for some windows
          "opaque,class:PPSSPPSDL"
          "opaque,class:xournalpp"
        ];
        #blurls = [
        #  "waybar"
        #];
        exec-once = [
          # Lock on Start
          #"${pkgs.swaylock-effects}/bin/swaylock -fF"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        ];
        exec = [
          "${lock}"
          "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
        ];
      };
  };
}
