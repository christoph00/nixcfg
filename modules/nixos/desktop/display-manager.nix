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
    set $ws3 "3: Bottles"
    set $ws4 "4: Misc"
    set $ws5 "5: Browser"

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

    # assign [app_id="steam"] $ws2
    # assign [class="steam"] $ws2
    #
    # assign [app_id="bottles"] $ws3
    # assign [class="^Bottles$"] $ws3
    #
    # assign [app_id="limo"] $ws4
    # assign [app_id="nautilus"] $ws4
    #
    # assign [app_id="firefox-beta"] $ws5
    #
    # assign [class=".*"] $ws1


    bindsym $mod+Shift+q kill
    bindsym $mod+d exec uwsm-app ${pkgs.anyrun}/bin/anyrun

    bindsym $mod+1 workspace $ws1
    bindsym $mod+2 workspace $ws2
    bindsym $mod+3 workspace $ws3
    bindsym $mod+4 workspace $ws4
    bindsym $mod+5 workspace $ws5




  '';
in
{
  options.desktop = {
    displayManager = mkOpt (enum [
      "tuigreet"
      "cosmic-greeter"
      "regreet"
      "ly"
    ]) "tuigreet";
    autologin = mkBoolOpt true;
    greetd = mkBoolOpt (cfg.displayManager == "tuigreet" || cfg.displayManager == "cosmic-greeter");
  };
  config = mkIf cfg.enable {
    sys.state.directories = [
      "/var/lib/cosmic-greeter"
      "/var/lib/regreet"
      "/var/lib/greetd"
    ];

    programs.regreet.enable = cfg.displayManager == "regreet";

    services.displayManager.ly = {
      enable = cfg.displayManager == "ly";
      settings = {
        clear_password = true;
        vi_mode = false;
        animation = "Doom";
        bigclock = true;
        # session_log = null;
      };
    };
    sys.state.files = ["/etc/ly/save.ini"];
    services.displayManager.ly.x11Support = false;
    systemd.user.targets.nixos-fake-graphical-session = lib.mkForce { };

    services.greetd = {
      enable = cfg.greetd;
      restart = false;

      settings = {
        vt = "7";
        default_session = mkIf (cfg.displayManager == "tuigreet") {
          user = "greeter";
          command = concatStringsSep " " [
            (getExe pkgs.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            "--sessions '${sessionPath}'"
          ];
        };
        initial_session = mkIf cfg.autologin {
          # command = "${getExe config.programs.uwsm.package} start -F -S -N gamewm ${gamewm}/bin/gamewm";
          command = "${getExe config.programs.uwsm.package} start -F labwc.desktop";
          user = "christoph";
        };
      };
    };
    services.displayManager.cosmic-greeter.enable = cfg.displayManager == "cosmic-greeter";
  };
}
