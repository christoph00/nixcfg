{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf (config.nos.type == "laptop") {
    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;

    environment.systemPackages = [pkgs.powertop pkgs.powerstat];

    services.fprintd.enable = true;

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
