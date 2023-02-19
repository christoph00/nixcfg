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

  # The sudo wrapper doesn't work in FHS environments. For our purposes
  # we add a passthrough sudo command that does not actually escalate
  # privileges.
  #
  # <https://github.com/NixOS/nixpkgs/issues/42117>
  passthroughSudo = writeShellScriptBin "sudo" ''
    declare -a final
    positional=""
    for value in "$@"; do
      if [[ -n "$positional" ]]; then
        final+=("$value")
      elif [[ "$value" == "-n" ]]; then
        :
      else
        positional="y"
        final+=("$value")
      fi
    done
    exec "''${final[@]}"
  '';

  # Null SteamOS updater that does nothing
  #
  # This gets us past the OS update step in the OOBE wizard.
  nullOsUpdater = writeShellScriptBin "steamos-update" ''
    >&2 echo "steamos-update: Not supported on NixOS - Doing nothing"
    exit 7;
  '';

  # Null Steam Deck BIOS updater that does nothing
  nullBiosUpdater = writeShellScriptBin "jupiter-biosupdate" ''
    >&2 echo "jupiter-biosupdate: Doing nothing"
  '';

  # A very simplistic "session switcher." All it does is kill gamescope.
  sessionSwitcher = writeShellScriptBin "steamos-session-select" ''
    session="''${1:-gamescope}"
    >>~/gamescope.log echo "steamos-session-select: switching to $session"
    if [[ "$session" != "plasma" ]]; then
      >&2 echo "!! Unsupported session '$session'"
      >&2 echo "Currently this can only be called by Steam to switch to Desktop Mode"
      exit 1
    fi
    mkdir -p ~/.local/state
    >~/.local/state/steamos-session-select echo "$session"
    if [[ -n "$gamescope_pid" ]]; then
      kill "$gamescope_pid"
    else
      >&2 echo "!! Don't know how to kill gamescope"
      exit 1
    fi
  '';

  sessionPath = lib.makeBinPath [
    mangohud
    systemd
    steam-with-packages
    steam-with-packages.run
    nullOsUpdater
    nullBiosUpdater
    sessionSwitcher
    passthroughSudo
  ];

  sessionEnvironment = builtins.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k}=${v}") {
    # Set input method modules for Qt/GTK that will show the Steam keyboard
    QT_IM_MODULE = "steam";
    GTK_IM_MODULE = "Steam";

    # Enable volume key management via steam for this session
    STEAM_ENABLE_VOLUME_HANDLER = "1";

    # Have SteamRT's xdg-open send http:// and https:// URLs to Steam
    SRT_URLOPEN_PREFER_STEAM = "1";

    # Disable automatic audio device switching in steam, now handled by wireplumber
    STEAM_DISABLE_AUDIO_DEVICE_SWITCHING = "1";

    # Enable support for xwayland isolation per-game in Steam
    STEAM_MULTIPLE_XWAYLANDS = "1";

    # We have the Mesa integration for the fifo-based dynamic fps-limiter
    STEAM_GAMESCOPE_DYNAMIC_FPSLIMITER = "1";

    # We have gamma/degamma exponent support
    STEAM_GAMESCOPE_COLOR_TOYS = "1";

    # We have NIS support
    STEAM_GAMESCOPE_NIS_SUPPORTED = "1";

    # Support for gamescope tearing with GAMESCOPE_ALLOW_TEARING atom (3.11.44+)
    STEAM_GAMESCOPE_HAS_TEARING_SUPPORT = "1";

    # Enable tearing controls in steam
    STEAM_GAMESCOPE_TEARING_SUPPORTED = "1";

    # When set to 1, a toggle will show up in the steamui to control whether dynamic refresh rate is applied to the steamui
    STEAM_GAMESCOPE_DYNAMIC_REFRESH_IN_STEAM_SUPPORTED = "1";

    # Enable VRR controls in steam
    STEAM_GAMESCOPE_VRR_SUPPORTED = "1";

    # Set refresh rate range and enable refresh rate switching
    STEAM_DISPLAY_REFRESH_LIMITS = "40,60";

    # We no longer need to set GAMESCOPE_EXTERNAL_OVERLAY from steam, mangoapp now does it itself
    STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND = "1";

    # Enable horizontal mangoapp bar
    STEAM_MANGOAPP_HORIZONTAL_SUPPORTED = "0";

    STEAM_USE_DYNAMIC_VRS = "1";

    # Don't wait for buffers to idle on the client side before sending them to gamescope
    vk_xwayland_wait_ready = "false";

    # To expose vram info from radv's patch we're including
    WINEDLLOVERRIDES = "dxgi=n";

    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";

    RADV_PERFTEST = "gpl";
  });

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
    exec steam -tenfoot -language german "$@"
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

    ${pkgs.sudo}/bin/sudo chown -R christoph:users /tmp/.X11-unix
    exec ${pkgs.kde-cli-tools}/bin/kde-inhibit --power --colorCorrect -- ${gamescope}/bin/gamescope "$@"
  '';

  # TODO: consume width/height script input params
  # TODO: consume script input param to disable fullscreening
  # TODO: pass down unhandled arguments
  # Script that launches the gamescope shim within a systemd scope.
  steam-session = writeShellScriptBin "steam-session" ''
    #GAMESCOPE_WIDTH=''${GAMESCOPE_WIDTH:-1920}
    #GAMESCOPE_HEIGHT=''${GAMESCOPE_HEIGHT:-1080}
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
      #-w $GAMESCOPE_WIDTH -h $GAMESCOPE_HEIGHT
      #-w 1920 -h 1080 -W 3840 -H 2160
      #-w 1920 -h 1080 -W 2560 -H 1440
      #-Y
      --fullscreen
      --prefer-output HDMI-A-1
      --generate-drm-mode fixed
      #--max-scale 2
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

  steam-session-desktop = writeTextFile {
    name = "steam-session-desktop";
    destination = "/share/applications/steam-wayland.desktop";
    text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Name=Steam UI
      Exec=${steam-session}/bin/steam-session
      Icon=steam
      Type=Application
      DesktopNames=steamui
    '';
  };
  steam-session-wayland =
    (writeTextFile {
      name = "steam-session-desktop";
      destination = "/share/wayland-sessions/steam-wayland.desktop";
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Name=Steam UI
        Exec=${steam-session}/bin/steam-session
        Icon=steam
        Type=Application
        DesktopNames=steamui
      '';
    })
    // {
      providedSessions = ["steam-wayland"];
    };
in {
  boot.kernel.sysctl."vm.max_map_count" = 262144;

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.steam-hardware.enable = mkDefault true;
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "*";
      item = "nofile";
      type = "soft";
      value = "unlimited";
    }
    {
      domain = "*";
      item = "nofile";
      type = "hard";
      value = "unlimited";
    }
  ];

  environment.systemPackages = [gamescope steam-session-desktop];
  programs.steam.enable = true;
  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
  programs.steam.package = pkgs.steam-with-packages;
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  services.xserver.displayManager.sessionPackages = [steam-session-wayland];
  # systemd.user.services.x11-ownership = rec {
  #   serviceConfig.Type = "oneshot";
  #   script = ''
  #     ${pkgs.sudo}/bin/sudo chown -R christoph:users /tmp/.X11-unix
  #   '';
  #   after = ["graphical-session.target"];
  #   wants = after;
  #   wantedBy = ["graphical-session-pre.target"];
  # };

  systemd.user.services.steamui = {
    description = "Steam UI";
    partOf = ["graphical-session.target"];
    script = "${steam-session}/bin/steam-session";
  };
  systemd.user.services.steam = {
    description = "Steam";
    partOf = ["graphical-session.target"];

    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;
      RADV_PERFTEST = "gpl";
    };
    script = ''
      ${pkgs.steam-with-packages}/bin/steam -language german -silent
    '';
  };
}
