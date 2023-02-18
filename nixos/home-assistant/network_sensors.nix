{pkgs, ...}: let
  mkPingSensor = host: name: {
    platform = "ping";
    inherit name;
    inherit host;
    count = 2;
    scan_interval = 5;
  };
in {
  services.home-assistant.config = {
    binary_sensor = [(mkPingSensor "tower.lan.net.r505.de" "tower")];
    # device_tracker = [
    #   {
    #     platform = "ping";
    #     hosts = {
    #       tower = "tower.lan.net.r505.de";
    #       shield = "shield.lan.net.r505.de";
    #       magentatv = "magentatv.lan.net.r505.de";
    #       air13 = "air13.lan.net.r505.de";
    #     };
    #   }
    # ];
  };
}
