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

  exec-wm = pkgs.writeShellScriptBin "exec-wm" ''
    env \
    WLR_NO_HARDWARE_CURSORS=0 \
    WLR_BACKENDS=drm,headless,libinput \
    WAYLAND_DISPLAY=gamescope-0 \
    UWSM_WAIT_VARNAMES_SETTLETIME=2
    ${getExe config.programs.uwsm.package} start -F -S -N steam \
    gamescope -- --steam --backend headless --rt --force-grab-cursor --expose-wayland -F fsr  -- \
    steam -tenfoot -pipewire-dmabuf -steamos3 -steamdeck &
    GAMESCOPE_PID=$!
    uwsm finalize 
    wait $GAMESCOPE_PID
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

    environment.systemPackages = [ exec-wm ];

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
          command = "${exec-wm}/bin/exec-wm";
          user = "christoph";
        };
      };
    };
    services.displayManager.cosmic-greeter.enable = cfg.displayManager == "cosmic-greeter";
  };
}
