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
  toTOML = (pkgs.formats.toml {}).generate;
in {
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
            "${pkgs.waylock}/bin/waylock -fork-on-lock"
            "${config.chr.desktop.ags.package}/bin/ags"
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
          "$mod" = "SUPER";
          bind = [
            "$mod, Return, exec, kitty"
            "$mod, c, killactive "
            "$mod, r, exec, ags -t applauncher"
            "$mod, f, fullscreen,0"
            "$mod, v, togglefloating"
            "$mod, R, pseudo, # dwindle"
            "$mod, E, togglesplit, # dwindle"

            "$mod + SHIFT, p, exec, hyprland-relative-workspace b"
            "$mod + SHIFT, n, exec, hyprland-relative-workspace f"

            # Switch workspaces with mod + [0-9]
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"
            "$mod, h, workspace, 11"
            "$mod, j, workspace, 12"
            "$mod, k, workspace, 13"
            "$mod, l, workspace, 14"

            # Move active window to a workspace with mod + SHIFT + [0-9]
            "$mod + SHIFT, 1, movetoworkspacesilent, 1"
            "$mod + SHIFT, 2, movetoworkspacesilent, 2"
            "$mod + SHIFT, 3, movetoworkspacesilent, 3"
            "$mod + SHIFT, 4, movetoworkspacesilent, 4"
            "$mod + SHIFT, 5, movetoworkspacesilent, 5"
            "$mod + SHIFT, 6, movetoworkspacesilent, 6"
            "$mod + SHIFT, 7, movetoworkspacesilent, 7"
            "$mod + SHIFT, 8, movetoworkspacesilent, 8"
            "$mod + SHIFT, 9, movetoworkspacesilent, 9"
            "$mod + SHIFT, 0, movetoworkspacesilent, 10"
            "$mod + SHIFT, h, movetoworkspacesilent, 11"
            "$mod + SHIFT, j, movetoworkspacesilent, 12"
            "$mod + SHIFT, k, movetoworkspacesilent, 13"
            "$mod + SHIFT, l, movetoworkspacesilent, 14"

            # Move window with mod_SHIFT + arrow keys
            "$mod + SHIFT, left, movewindow, l"
            "$mod + SHIFT, right, movewindow, r"
            "$mod + SHIFT, up, movewindow, u"
            "$mod + SHIFT, down, movewindow, d"

            # Scroll through existing workspaces with mod + scroll
            "$mod, mouse_up, workspace, r+1"
            "$mod, mouse_down, workspace, r-1"

            "$mod + SHIFT, R, exec, ${inputs.anyrun.packages.${pkgs.system}.anyrun}/bin/anyrun"
            "$mod + SHIFT, F, exec, ${pkgs.gnome.nautilus}/bin/nautilus"

            "$mod, s, exec, ${pkgs.hyprshade}/bin/hyprshade toggle"
          ];

          bindm = [
            # Move/resize windows with $mod + LMB/RMB and dragging
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
      };

      xdg.configFile."hyprshade/config.toml".source = toTOML "config.toml" {
        shades = [
          {
            name = "blue-light-filter";
            start_time = "19:00:00";
            end_time = "08:00:00";
          }
        ];
      };
    };
  };
}
