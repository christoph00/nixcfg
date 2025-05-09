{
  flake,
  lib,
  config,
  ...
}:
let
  inherit (flake.lib) mkOpt enabled;
  inherit (lib) mkForce;
in
{
  config = {

    environment.variables.BROWSER = "echo";
    systemd = {
      enableEmergencyMode = false;

      watchdog = {
        runtimeTime = "20s";
        rebootTime = "30s";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
