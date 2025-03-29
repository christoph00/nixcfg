{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:
let
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [ pkgs.fuzzel ];
    text = ''
      OPTIONS=(
        " Lock"
        " Suspend"
        " Reboot"
        " Power off"
        " Log out"
      )

      CHOICE=$(printf '%s\n' "''${OPTIONS[@]}" | fuzzel --dmenu --cache /dev/null)

      case $CHOICE in
      *"Lock") loginctl lock-session ;;
      *"Suspend") systemctl suspend ;;
      *"Reboot") systemctl reboot ;;
      *"Power off") systemctl poweroff ;;
      *"Log out") niri msg action quit ;;
      esac
    '';
  };

  lock-screen = pkgs.writeShellScript "lock-screen" ''
    set -euo pipefail

    ${lib.getExe pkgs.niri-unstable} msg action do-screen-transition --delay-ms 1000
    ${lib.getExe pkgs.gtklock} -d
  '';

  niri-focus-any-window = pkgs.writeShellScript "niri-focus-any-window" ''
    set -euo pipefail

    # sort to have focused window as the last result
    formatWindows='sort_by(.is_focused) | .[] | "\(.id | tostring):\t\(.title) (\(.app_id))"'

    selection="$(${pkgs.niri}/bin/niri msg --json windows \
      | ${pkgs.jq}/bin/jq -r "$formatWindows" \
      | ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt "Focus window..." 2> /dev/null \
      | cut -d: -f1)"

    exec ${pkgs.niri}/bin/niri msg action focus-window --id "$selection"
  '';

in

{
  home.packages = with pkgs; [
    brightnessctl
    libnotify
    wofi
    rofi
    fuzzel
    xwayland-satellite
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [
        "gtk"
        "gnome"
      ];
      "org.freedesktop.impl.portal.Settings" = "gtk";
    };
  };

  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "de";
          };
        };
        touchpad = {
          click-method = "clickfinger";
          natural-scroll = true;
          tap = true;
        };
        warp-mouse-to-focus = true;
        focus-follows-mouse = { };
      };
      environment = {
        XDG_SESSION_DESKTOP = "niri";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";
        NIXOS_OZONE_WL = "1";
        TERM = "ghostty";
      };
      spawn-at-startup = [
        {
          command = [
            "uwsm"
            "finalize"
            "FINALIZED=\"I'm here\""
            "WAYLAND_DISPLAY"
          ];
        }

        {
          command = [
            "uwsm"
            "app"
            "xwayland-satellite"
          ];
        }
      ];
      binds =
        with config.lib.niri.actions;
        {

          "Mod+Escape".action.spawn = [ "${lib.getExe powerMenu}" ];
          "Mod+Return".action.spawn = [ "${inputs.ghostty.packages.${pkgs.system}.default}/bin/ghostty" ];

          "Mod+Tab".action = focus-column-right-or-first;

          "XF86Favorites".action.spawn = [ "${pkgs.wofi}/bin/wofi -dmenu -i -show bookmarks" ];
          "XF86PickupPhone".action.spawn = [ "" ];
          "XF86HangupPhone".action.spawn = [ "" ];
          "XF86NotificationCenter".action.spawn = [ "" ];
          "XF86Display".action.spawn = [ "" ];

          "XF86AudioMute".action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "-l"
            "1.4"
            "@DEFAULT_AUDIO_SINK@"
            "2%-"
          ];
          "XF86AudioRaiseVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "-l"
            "1.4"
            "@DEFAULT_AUDIO_SINK@"
            "2%+"
          ];
          "XF86AudioPrev".action.spawn = [
            "playerctl"
            "previous"
          ];
          "XF86AudioPlay".action.spawn = [
            "playerctl"
            "play-pause"
          ];
          "xf86audioNext".action.spawn = [
            "playerctl"
            "next"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "brightnessctl"
            "set"
            "2%-"
          ];
          "XF86MonBrightnessUp".action.spawn = [
            "brightnessctl"
            "set"
            "+2%"
          ];

          "Mod+Space".action.spawn = [
            "wofi"
            "--allow-images"
            "--insensitive"
            "--show"
            "drun"
          ];
          "Mod+D".action.spawn = [ "${pkgs.anyrun}/bin/anyrun" ];

          "Ctrl+Alt+V".action.spawn = [
            "sh"
            "-c"
            "${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | wl-copy"
          ];

          "Mod+Q".action = close-window;
          "Mod+S".action = switch-preset-column-width;
          "Mod+F".action = maximize-column;
          # "Mod+Shift+F".action = fullscreen-window;
          "Mod+Shift+F".action = expand-column-to-available-width;
          "Mod+W".action = toggle-column-tabbed-display;
          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;
          "Mod+C".action = center-window;

          "Mod+H".action = focus-column-left;
          "Mod+L".action = focus-column-right;
          "Mod+J".action = focus-window-or-workspace-down;
          "Mod+K".action = focus-window-or-workspace-up;
          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Down".action = focus-workspace-down;
          "Mod+Up".action = focus-workspace-up;

          "Mod+Shift+H".action = move-column-left;
          "Mod+Shift+L".action = move-column-right;
          "Mod+Shift+K".action = move-column-to-workspace-up;
          "Mod+Shift+J".action = move-column-to-workspace-down;

          "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;

          "Print".action.screenshot = [ ];
          "Ctrl+Print".action.screenshot-screen = [ ];
          "Alt+Print".action.screenshot-window = [ ];

        }
        // lib.attrsets.listToAttrs (
          builtins.concatMap (
            i: with config.lib.niri.actions; [
              {
                name = "Mod+${toString i}";
                value.action = focus-workspace i;
              }
              {
                name = "Mod+Shift+${toString i}";
                value.action = move-window-to-workspace i;
              }
            ]
          ) (lib.range 1 9)
        );

      prefer-no-csd = false;
      layout = {
        always-center-single-column = true;
        gaps = 4;
        border.enable = false;
        focus-ring.enable = false;
        shadow.enable = true;
        tab-indicator = {
          hide-when-single-tab = true;
          place-within-column = true;
          position = "top";
        };
      };
      window-rules = [
        {
          clip-to-geometry = true;
          draw-border-with-background = false;
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-left = 8.0;
            bottom-right = 8.0;
          };
        }
      ];
    };
  };
}
