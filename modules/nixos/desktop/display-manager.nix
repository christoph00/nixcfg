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
  inherit (lib.types) nullOr enum;
  inherit (flake.lib) mkOpt mkBoolOpt;
  cfg = config.desktop;
  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
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
          command = "uwsm start -S -F /run/current-system/sw/bin/steam-gamescope";
          user = "christoph";
        };
      };
    };
    services.displayManager.cosmic-greeter.enable = cfg.displayManager == "cosmic-greeter";
  };
}
