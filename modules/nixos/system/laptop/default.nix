{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.laptop;
in {
  options.chr.system.laptop = with types; {
    enable = mkBoolOpt' (config.chr.type == "laptop");
  };

  config = mkIf cfg.enable {
    services.power-profiles-daemon.enable = true;
    #services.thermald.enable = false;
    services.tlp = {
      enable = false;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT1 = 70;
        STOP_CHARGE_THRESH_BAT1 = 80;
      };
    };

    environment.systemPackages = [pkgs.powertop pkgs.powerstat];

    services.fprintd.enable = true;

    services.upower.enable = true;

    networking.wireless = {
      enable = false;
      fallbackToWPA2 = false;
      iwd = {
        enable = true;
        settings = {
          General.AddressRandomization = "once";
          General.AddressRandomizationRange = "full";
        };
      };

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

    networking.networkmanager.wifi.backend = "iwd";
  };
}
