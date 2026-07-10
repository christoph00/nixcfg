{
  lib,
  flake,
  config,
  options,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf concatStringsSep getExe;
  inherit (lib.types) enum;
  inherit (flake.lib) mkOpt mkBoolOpt;
  cfg = config.desktop;
  up = perSystem.nixpkgs-unstable;
  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
in
{
  options.desktop = {
    displayManager = mkOpt (enum [
      "tuigreet"
      "cosmic-greeter"
      "regreet"
      "ly"
      "sddm"
      "dms"
    ]) "tuigreet";
    autologin = mkBoolOpt true;
    greetd = mkBoolOpt (
      cfg.displayManager == "tuigreet"
      || cfg.displayManager == "cosmic-greeter"
      || cfg.displayManager == "regreet"
    );
  };

  config = mkIf cfg.enable {
    sys.state.directories =
      lib.optional (cfg.displayManager == "cosmic-greeter") "/var/lib/cosmic-greeter"
      ++ lib.optional (cfg.displayManager == "regreet") "/var/lib/regreet"
      ++ lib.optional cfg.greetd "/var/lib/greetd"
      ++ lib.optional (cfg.displayManager == "sddm") "/var/lib/sddm";

    programs.regreet.enable = cfg.displayManager == "regreet";

    services.greetd = {
      enable = cfg.greetd;
      restart = false;
      settings = {
        vt = "7";
        default_session = mkIf (cfg.displayManager == "tuigreet") {
          user = "greeter";
          command = concatStringsSep " " [
            (getExe up.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            "--sessions '${sessionPath}'"
          ];
        };
        initial_session = mkIf cfg.autologin {
          command = "${getExe config.programs.uwsm.package} start -F labwc.desktop";
          user = "christoph";
        };
      };
    };



    services.displayManager.dms-greeter = {
      enable = cfg.displayManager == "dms";
      compositor.name = "sway";
    };

    services.displayManager.cosmic-greeter.enable = cfg.displayManager == "cosmic-greeter";
    services.displayManager.sddm = {
      enable = cfg.displayManager == "sddm";
      wayland.enable = true;
    };
  };
}
