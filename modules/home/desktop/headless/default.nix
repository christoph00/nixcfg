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
        Unit = {
        Description = "Systemd service for Lan Mouse";
        PartOf = [ "graphical-session.target" ];
         After = [ "graphical-session-pre.target" ];

      };
      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/lan-mouse --daemon";
      };
      Install.WantedBy = [
        (lib.mkIf cfg.autorun "default.target")
      ];




  
      #environment.PATH = lib.mkForce null;
      Service = {
        Type = "simple";
        #ExecStart = "wayfire"; #${pkgs.dbus}/bin/dbus-run-session 
        ExecStart = "${config.profiles.internal.desktop.wayfire.finalPackage}/bin/wayfire";

      };
    

  };
  };
}
