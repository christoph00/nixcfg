{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.hyprland;
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in {
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  options.chr.desktop.hyprland = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not enable Hyprland Desktop.";
    scale = lib.mkOption {
      type = lib.types.str;
      default = "1";
    };
    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
    };
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
    services.greetd = {
      enable = true;
      settings = {
        # default_session.command = ''
        #   ${pkgs.greetd.tuigreet}/bin/tuigreet --remember --user-menu --asterisks --time --greeting "Welcome to NixOS" --cmd ${plasma}/bin/plasma'';
        initial_session = {
          command = "${config.programs.hyprland.package}/bin/Hyprland";
          user = config.chr.user.name;
        };
      };
    };
    programs.regreet.enable = true;
    environment.persistence."${config.chr.system.persist.stateDir}".directories = lib.mkIf config.chr.system.persist.enable ["/var/cache/regreet"];

    security = {
      polkit.enable = true;
      pam.services.ags = {};
    };

    environment.systemPackages = with pkgs.gnome; [
      pkgs.loupe
      adwaita-icon-theme
      nautilus
      baobab
      gnome-calendar
      gnome-boxes
      gnome-system-monitor
      gnome-control-center
      gnome-weather
      gnome-calculator
      gnome-clocks
    ];

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    environment.variables.NIXOS_OZONE_WL = "1";

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      accounts-daemon.enable = true;
      gnome = {
        evolution-data-server.enable = true;
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-online-accounts.enable = true;
      };
    };

    chr.home.extraOptions = {
      wayland.windowManager.hyprland = {
        enable = true;
        package = config.programs.hyprland.package;
        settings = {
          exec-once = [
            "hyprlock"
            "${config.chr.desktop.ags.package}/bin/ags -b hypr"
            "wl-paste --type text --watch cliphist store" #Stores only text data
            "wl-paste --type image --watch cliphist store"
            "${pkgs.hyprshade}/bin/hyprshade auto"
          ];
          animations = {
            enabled = "yes";

            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            bezier = [
              "easein, 0.47, 0, 0.745, 0.715"
              "myBezier, 0.05, 0.9, 0.1, 1.05"
              "overshot, 0.13, 0.99, 0.29, 1.1"
              "scurve, 0.98, 0.01, 0.02, 0.98"
            ];

            animation = [
              "border, 1, 10, default"
              "fade, 1, 10, default"
              "windows, 1, 5, overshot, popin 10%"
              "windowsOut, 1, 7, default, popin 10%"
              "workspaces, 1, 6, overshot, slide"
            ];
          };

          decoration = {
            active_opacity = 0.95;
            fullscreen_opacity = 1.0;
            inactive_opacity = 0.9;
            rounding = 4;

            blur = {
              enabled = "yes";
              passes = 4;
              size = 5;
            };
            blurls = ["gtk-layer-shell" "waybar" "lockscreen" "ironbar"];

            drop_shadow = true;
            shadow_ignore_window = true;
            shadow_range = 20;
            shadow_render_power = 3;
            "col.shadow" = "0x55161925";
            "col.shadow_inactive" = "0x22161925";
          };

          dwindle = {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            force_split = 0;
            preserve_split = true; # you probably want this
            pseudotile = true; # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
          };

          general = {
            allow_tearing = true;
            border_size = 2;
            "col.active_border" = "rgba(414868FF)";
            "col.inactive_border" = "rgb(24283b)";
            gaps_in = 5;
            gaps_out = 5;
            layout = "dwindle";
            no_cursor_warps = true;
          };

          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
            workspace_swipe_invert = false;
          };

          monitor = [
            ",preferred,auto,${cfg.scale}"
          ];

          input = {
            follow_mouse = 1;
            kb_layout = cfg.layout;

            touchpad = {
              natural_scroll = "no";
              disable_while_typing = true;
              tap-to-click = true;
            };

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          };

          master = {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = true;
          };

          misc = {
            disable_hyprland_logo = true;
            key_press_enables_dpms = true;
            mouse_move_enables_dpms = true;
            vrr = 2;
          };

          windowrule = let
            f = regex: "float, ^(${regex})$";
          in [
            (f "org.gnome.Calculator")
            (f "org.gnome.Nautilus")
            (f "pavucontrol")
            (f "nm-connection-editor")
            (f "blueberry.py")
            (f "org.gnome.Settings")
            (f "org.gnome.design.Palette")
            (f "Color Picker")
            (f "xdg-desktop-portal")
            (f "xdg-desktop-portal-gnome")
            (f "transmission-gtk")
            (f "com.github.Aylur.ags")
          ];

          bind = let
            binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
            mvfocus = binding "SUPER" "movefocus";
            ws = binding "SUPER" "workspace";
            resizeactive = binding "SUPER CTRL" "resizeactive";
            mvactive = binding "SUPER ALT" "moveactive";
            mvtows = binding "SUPER SHIFT" "movetoworkspace";
            e = "exec, ags -b hypr";
            arr = [1 2 3 4 5 6 7 8 9];
          in
            [
              "CTRL SHIFT, R,  ${e} quit; ags -b hypr"
              "SUPER, R,       ${e} -t applauncher"
              "SUPER, Tab,     ${e} -t overview"
              ",XF86PowerOff,  ${e} -r 'powermenu.shutdown()'"
              "SUPER, Return, exec, kitty"
              "SUPER, W, exec, thorium"
              "SUPER, E, exec, wezterm -e lf"

              "SUPER SHIFT, R, exec, ${inputs.anyrun.packages.${pkgs.system}.anyrun}/bin/anyrun"

              "$SUPER, s, exec, ${pkgs.hyprshade}/bin/hyprshade toggle"

              "ALT, Tab, focuscurrentorlast"
              "CTRL ALT, Delete, exit"
              "ALT, Q, killactive"
              "SUPER, F, togglefloating"
              "SUPER, G, fullscreen"
              "SUPER, O, fakefullscreen"
              "SUPER, P, togglesplit"

              (mvfocus "k" "u")
              (mvfocus "j" "d")
              (mvfocus "l" "r")
              (mvfocus "h" "l")
              (ws "left" "e-1")
              (ws "right" "e+1")
              (mvtows "left" "e-1")
              (mvtows "right" "e+1")
              (resizeactive "k" "0 -20")
              (resizeactive "j" "0 20")
              (resizeactive "l" "20 0")
              (resizeactive "h" "-20 0")
              (mvactive "k" "0 -20")
              (mvactive "j" "0 20")
              (mvactive "l" "20 0")
              (mvactive "h" "-20 0")
            ]
            ++ (map (i: ws (toString i) (toString i)) arr)
            ++ (map (i: mvtows (toString i) (toString i)) arr);

          bindle = [
            ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
            ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
            ",XF86KbdBrightnessUp,   exec, ${brightnessctl} -d asus::kbd_backlight set +1"
            ",XF86KbdBrightnessDown, exec, ${brightnessctl} -d asus::kbd_backlight set  1-"
            ",XF86AudioRaiseVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
            ",XF86AudioLowerVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ];

          bindl = [
            ",XF86AudioPlay,    exec, ${playerctl} play-pause"
            ",XF86AudioStop,    exec, ${playerctl} pause"
            ",XF86AudioPause,   exec, ${playerctl} pause"
            ",XF86AudioPrev,    exec, ${playerctl} previous"
            ",XF86AudioNext,    exec, ${playerctl} next"
            ",XF86AudioMicMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ];

          bindm = [
            "SUPER, mouse:273, resizewindow"
            "SUPER, mouse:272, movewindow"
          ];
        };
      };

      xdg.configFile."hyprshade/config.toml".text = ''
        [[shades]]
        name = blue-light-filter
        start_time = 19:00:00
        end_time = 08:00:00
      '';

      xdg.configFile."hypr/shaders/blue-light-filter.glsl" = {
        # https://github.com/hyprwm/Hyprland/issues/1140#issuecomment-1335128437
        text = ''
          precision mediump float;
          varying vec2 v_texcoord;
          uniform sampler2D tex;

          const float temperature = 2600.0;
          const float temperatureStrength = 1.0;

          #define WithQuickAndDirtyLuminancePreservation
          const float LuminancePreservationFactor = 1.0;

          // function from https://www.shadertoy.com/view/4sc3D7
          // valid from 1000 to 40000 K (and additionally 0 for pure full white)
          vec3 colorTemperatureToRGB(const in float temperature){
              // values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693
              mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                                      vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                                      vec3(1.0, 1.3302673723350029, 1.8993753891711275)) :
                                                 mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                                      vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                                      vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
              return mix(
                  clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
                  vec3(1.0),
                  smoothstep(1000.0, 0.0, temperature)
              );
          }

          void main() {
              vec4 pixColor = texture2D(tex, v_texcoord);

              // RGB
              vec3 color = vec3(pixColor[0], pixColor[1], pixColor[2]);

          #ifdef WithQuickAndDirtyLuminancePreservation
              color *= mix(1.0,
                           dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                           LuminancePreservationFactor);
          #endif

              color = mix(color, color * colorTemperatureToRGB(temperature), temperatureStrength);

              vec4 outCol = vec4(color, pixColor[3]);

              gl_FragColor = outCol;
          }
        '';
      };
    };
  };
}
