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
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.headless;

in
{
  options.profiles.internal.desktop.headless = with types; {
    enable = mkBoolOpt false "Enable Headless Desktop";
    autorun = mkBoolOpt true "Auto Start Service";
  };

  config = mkIf cfg.enable {

    systemd.user.services.headless-desktop = {

      wantedBy = optional cfg.autorun "default.target";
      bindsTo = [ "graphical-session.target" ];

      description = "Graphical headless Desktop";
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        #ExecStart = "wayfire"; #${pkgs.dbus}/bin/dbus-run-session 
        ExecStart = "${config.profiles.internal.desktop.wayfire.finalPackage}/bin/wayfire";

      };
    };

  };
}
