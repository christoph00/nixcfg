{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "22.11";
  hardware.enableRedistributableFirmware = true;

  # TODO: Check if Home Net
  networking.domain = "lan.net.r505.de";

  systemd.network.networks = {
    lan = {
      DHCP = "yes";
      matchConfig.Name = "en*";
    };
  };
}
