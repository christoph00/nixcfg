{
  config,
  lib,
  pkgs,
  ...
}: {
  # Lid settings
  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
      IdleAction=hybrid-sleep
      IdleActionSec=30min
    '';
  };

  services.power-profiles-daemon.enable = true;
}
