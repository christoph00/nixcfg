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

  systemd.network.networks = {
    wifi = {
      DHCP = "yes";
      matchConfig.Name = "wl*";
    };
  };

  networking.wireless = {
    enable = false;
    iwd.enable = true;
    fallbackToWPA2 = false;

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
    extraConfig = ''
      update_config=1
    '';
  };
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/iwd"
    ];
  };
}
