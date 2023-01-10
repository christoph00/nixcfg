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
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/iwd"
    ];
  };

  systemd.user.timers.notify-on-low-battery = {
    timerConfig.OnBootSec = "2m";
    timerConfig.OnUnitInactiveSec = "2m";
    timerConfig.Unit = "notify-on-low-battery.service";
    wantedBy = ["timers.target"];
  };

  systemd.user.services.notify-on-low-battery = {
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      export battery_capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity)
      export battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/status)
      if [[ $battery_capacity -le 10 && $battery_status = "Discharging" ]]; then
        ${pkgs.libnotify}/bin/notify-send --urgency=critical "$battery_capacity%: See you, space cowboy..."
      fi
    '';
  };
}
