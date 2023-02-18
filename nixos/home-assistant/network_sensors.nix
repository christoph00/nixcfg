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
    binary_sensor = [
      (mkPingSensor "tower.lan.net.r505.de" "tower")
      (mkPingSensor "shield.lan.net.r505.de" "shield")
      (mkPingSensor "air13.lan.net.r505.de" "air13")
      (mkPingSensor "192.168.1.15" "uap")
      (mkPingSensor "1.1.1.1" "Internet IP")
      (mkPingSensor "telekom.de" "Internet DNS")
    ];
    device_tracker = [
      {
        platform = "ping";
        hosts = {
          s21 = "s21.lan.net.r505.de";
          s22u = "s22u.lan.net.r505.de";
          s8 = "s8.lan.net.r505.de";
        };
      }
    ];
  };
}
