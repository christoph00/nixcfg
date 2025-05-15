{
  pkgs,
  input,
  lib,
  flake,
  config,
  options,
  ...
}:
let
  inherit (flake.lib) mkBoolOpt;
  inherit (lib) mkIf;
  cfg = config.graphical;
in
{
  options.desktop = {
    remote = mkBoolOpt false;

  };

  config = mkIf cfg.remote {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = false;
      openFirewall = true;
    };

    systemd.user.services = {
      sunshine = {
        path = [ config.system.path ];
        serviceConfig.Slice = "background-graphical.slice";
        after = [ "graphical-session.target" ];
      };
    };

  };

}
