{
  lib,
  flake,
  config,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf concatStringsSep getExe;
  inherit (lib.types) enum;
  inherit (flake.lib) mkOpt mkBoolOpt;
  cfg = config.desktop;
  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];

  gamewm = pkgs.writeShellScriptBin "gamewm" ''
    set -xeuo pipefail
    env \
    WLR_NO_HARDWARE_CURSORS=0 \
    WLR_BACKENDS=drm,headless,libinput \
    WLR_LIBINPUT_NO_DEVICES=1 \
    XKB_DEFAULT_LAYOUT=de
    /run/current-system/sw/bin/sway -c ${gamewm-conf}
    # gamescope --steam --backend headless --rt --force-grab-cursor --expose-wayland -F fsr  -- \
    # steam -tenfoot -pipewire-dmabuf -steamos3 -steamdeck &
    # GAMESCOPE_PID=$!
    # FINALIZED="I'm here" WAYLAND_DISPLAY=gamescope-0 uwsm finalize
    # wait $GAMESCOPE_PID
  '';

  gamewm-conf = pkgs.writeText "gamewm.conf" ''
    exec swaymsg create_output HEADLESS-1
    exec uwsm finalize SWAYSOCK WAYLAND_DISPLAY WLR_BACKENDS


    default_border normal
    default_floating_border normal

    set $mod Mod1

    set $ws1 "1: Game"
    set $ws2 "2: Steam"
    set $ws2 "3: Bottles"

    # seat seat0 fallback false
    # seat seat0 attach "48879:57005:Keyboard_passthrough"
    # seat seat0 attach "48879:57005:Mouse_passthrough"
    # seat seat0 attach "48879:57005:Pen_passthrough"
    # seat seat0 attach "48879:57005:Touch_passthrough"
    # # Sunshine without inputtino, remove when next release arrives
    # seat seat0 attach "1133:16440:Logitech_Wireless_Mouse_PID:4038"
    # seat seat0 attach "48879:57005:Touchscreen_passthrough"
    #

    input "48879:57005:Mouse_passthrough" pointer_accel -1

    assign [app_id="steam"] $ws2
    assign [class="^Steam$"] $ws2

    assign [app_id="bottles"] $ws3
    assign [class="^Bottles$"] $ws3

    assign [class=".*"] $ws1


    bindsym $mod+Shift+q kill
    bindsym $mod+d exec uwsm-app ${pkgs.anyrun}/bin/anyrun

    bindsym $mod+1 workspace $ws1
    bindsym $mod+2 workspace $ws2
    bindsym $mod+1 workspace $ws3




  '';
in
{
  options.desktop = {
    displayManager = mkOpt (enum [
      "greetd"
      "cosmic-greeter"
    ]) "greetd";
    autologin = mkBoolOpt false;
  };
  config = mkIf cfg.enable {

    services.greetd = mkIf (cfg.displayManager == "greetd") {
      enable = true;
      vt = 2;
      restart = true;

      settings = {
        default_session = {
          user = "greeter";
          command = concatStringsSep " " [
            (getExe pkgs.greetd.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            "--sessions '${sessionPath}'"
          ];
        };
        initial_session = mkIf cfg.autologin {
          command = "${getExe config.programs.uwsm.package} start -F -S -N gamewm ${gamewm}/bin/gamewm";
          # command = "${getExe config.programs.uwsm.package} start -F -S sway.desktop";
          user = "christoph";
        };
      };
    };
    services.displayManager.cosmic-greeter.enable = cfg.displayManager == "cosmic-greeter";
  };
}
