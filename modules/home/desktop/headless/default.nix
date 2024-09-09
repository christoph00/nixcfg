{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    optional
    asserts
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.headless;

in
{
  options.profiles.internal.desktop.headless = with types; {
    enable = mkBoolOpt false "Enable Headless Desktop";
    autorun = mkBoolOpt true "Auto Start Service";
    vnc = {
      addr = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Which address should wayvnc listen to.
        '';
      };
      maxFps = mkOption {
        type = types.int;
        default = 30;
        description = ''
          Set the rate limit.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 5900;
        description = ''
          Set the port to listen on.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [pkgs.wayvnc];

    xdg.configFile."wayvnc/config".text = ''
      port=${toString cfg.vnc.port}
    '';

    systemd.user.services.wayvnc = {
      Unit = {
        Description = "a VNC server for wlroots based Wayland compositors";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Restart = "on-failure";
        ExecStart = ''          ${pkgs.wayvnc}/bin/wayvnc \
                    -f ${assert asserts.assertMsg (cfg.vnc.maxFps > 0) "Rate limit for WayVNC must be a positive integer!"; toString maxFps} \
                    ${cfg.vnc.addr}
        '';
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    systemd.user.services.headless-desktop = {
      Unit = {
        Description = "Systemd service for Lan Mouse";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];

      };
      Install.WantedBy = [
        (lib.mkIf cfg.autorun "default.target")
      ];

      #environment.PATH = lib.mkForce null;
      Service = {
        Type = "simple";
        #ExecStart = "wayfire"; #${pkgs.dbus}/bin/dbus-run-session 
        ExecStart = " ${config.profiles.internal.desktop.wayfire.finalPackage}/bin/wayfire";

      };

    };
  };
}
