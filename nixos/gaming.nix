# https://github.com/Jovian-Experiments/Jovian-NixOS
{
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkDefault
    ;

  # Note that we override Steam in our overlay
  inherit
    (pkgs)
    gamescope
    mangohud
    systemd
    steam-with-packages
    writeTextFile
    writeShellScript
    writeShellScriptBin
    ;

  sessionPath = lib.makeBinPath [
    mangohud
    systemd
    steam-with-packages
    steam-with-packages.run
  ];

  sessionEnvironment = "RADV_PERFTEST=GPL WINEDLLOVERRIDES=dxgi=n";

  # Shim that runs steam and associated services.
  steam-shim = writeShellScript "steam-shim" ''
    export PATH=${sessionPath}:$PATH
    export STEAM_USE_MANGOAPP=1
    export MANGOHUD_CONFIGFILE=$(mktemp $XDG_RUNTIME_DIR/mangohud.XXXXXXXX)
    # Initially write no_display to our config file
    # so we don't get mangoapp showing up before Steam initializes
    # on OOBE and stuff.
    mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
    echo "no_display" > "$MANGOHUD_CONFIGFILE"
    # These additional services will be culled when the main service quits too.
    # This is done by re-using the same slice name.
    systemd-run --user \
      --collect \
      --slice="steam-session" \
      --unit=steam-session.mangoapp \
      --property=Restart=always \
      --setenv=DISPLAY \
      --setenv=MANGOHUD_CONFIGFILE \
      -- \
      mangoapp
    exec steam -steampal -bigpicture -gamepadui "$@"
  '';

  # Shim that runs gamescope, with a specific environment.
  # NOTE: This is only used to provide gamescope_pid.
  gamescope-shim = writeShellScript "gamescope-shim" ''
    # We will `exec` and thus replace the current process with
    # gamescope, which will in turn have the current PID.
    export gamescope_pid="''$$"
    # gamescope_pid is used by the `steamos-session-select` script.
    # TODO[Jovian]: Explore other ways to stop the session?
    #               -> `systemctl --user stop steam-session.slice`?
    exec ${gamescope}/bin/gamescope "$@"
  '';

  # TODO: consume width/height script input params
  # TODO: consume script input param to disable fullscreening
  # TODO: pass down unhandled arguments
  # Script that launches the gamescope shim within a systemd scope.
  steam-session = writeShellScriptBin "steam-session" ''
    GAMESCOPE_WIDTH=''${GAMESCOPE_WIDTH:-1920}
    GAMESCOPE_HEIGHT=''${GAMESCOPE_HEIGHT:-1080}
    SLICE="steam-session"
    runtime_dir="$XDG_RUNTIME_DIR/$SLICE.run"
    mkdir -p "$runtime_dir"
    export GAMESCOPE_STATS="$runtime_dir/stats.pipe"
    rm -f "$GAMESCOPE_STATS"
    mkfifo -- "$GAMESCOPE_STATS"
    # To play nice with the short term callback-based limiter for now
    #
    # This file is also read by the SteamOS version of Mesa/RADV to override
    # the swap interval.
    #
    # With pressure-vessel, only certain subpaths of $XDG_RUNTIME_DIR
    # are bind-mounted into the sandbox. As a result, we use --tmpdir here
    # instead of $runtime_dir.
    export GAMESCOPE_LIMITER_FILE=$(mktemp --tmpdir gamescope-limiter.XXXXXXXX)
    # Prepare our initial VRS config file for dynamic VRS in Mesa.
    #
    # Same as above.
    export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp --tmpdir radv_vrs.XXXXXXXX)
    echo "1x1" > "$RADV_FORCE_VRS_CONFIG_FILE"
    # Prepare gamescope mode save file (3.1.44+)
    gamescope_config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope"
    mkdir -p "$gamescope_config_dir"
    export GAMESCOPE_MODE_SAVE_FILE="$gamescope_config_dir/modes.cfg"
    touch "$GAMESCOPE_MODE_SAVE_FILE"
    gamescope_incantation=(
      "${gamescope-shim}"
      # Steam intrinsically knows it can use one of the layer for the
      # game, and the other for its overlay UI.
      # TODO[Jovian]: verify assertion
      --xwayland-count 2
      -w $GAMESCOPE_WIDTH -h $GAMESCOPE_HEIGHT
      -Y
      --fullscreen
      # TODO[Jovian]: document why '*' here
      #--prefer-output '*',eDP-1
      --generate-drm-mode fixed
      --max-scale 2
      #--default-touch-mode 4
      --hide-cursor-delay 3000
      --fade-out-duration 200
      --steam
      # Steam uses this
      # TODO[Jovian]: document how it's used?
      --stats-path "$GAMESCOPE_STATS"
      # Not needed when executing steam as a child process
      # --ready-fd "$socket"
      --
      systemd-run --user
        --collect
        --scope
        --slice="$SLICE"
      --
      "${steam-shim}" "$@"
    )
    at_exit() {
      systemctl --quiet --user stop "$SLICE.slice"
    }
    trap at_exit SIGINT SIGTERM EXIT
    PS4=" [steam-session] $ "
    set -x
    ${sessionEnvironment} "''${gamescope_incantation[@]}"
  '';

  steam-session-desktop =
    (writeTextFile {
      name = "steam-session-desktop";
      destination = "/share/wayland-sessions/steam-wayland.desktop";
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Name=Gaming Mode
        Exec=${steam-session}/bin/steam-session
        Icon=steamicon.png
        Type=Application
        DesktopNames=gamescope
      '';
    })
    // {
      providedSessions = ["steam-wayland"];
    };
in {
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.steam-hardware.enable = mkDefault true;

  environment.systemPackages = [steam-session];

  services.xserver.displayManager.sessionPackages = [steam-session-desktop];
}
