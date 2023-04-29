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
      (mkPingSensor "tower.ts" "tower")
      (mkPingSensor "shield.lan.net.r505.de" "shield")
      (mkPingSensor "air13.ts" "air13")
      (mkPingSensor "oc1.ts" "oc1")
      (mkPingSensor "oc2.ts" "oc2")
      (mkPingSensor "oca.ts" "oca")
      (mkPingSensor "192.168.1.15" "uap")
      (mkPingSensor "193.110.81.0" "Internet IP")
      (mkPingSensor "dns0.eu" "Internet DNS")
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
    switch = [
      {
        platform = "template";
        switches.tower = {
          unique_id = "8e86b540-f94c-4177-93a3-1146a9396494";
          value_template = "{{ is_state('binary_sensor.tower', 'on') }}";
          turn_on.service = "script.pc_ein";
          turn_off.service = "script.pc_aus";
        };
      }
    ];
  };
}
