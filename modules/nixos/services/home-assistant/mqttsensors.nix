{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.home-assistant;

  deviceR2S = {
    identifiers = "R2S";
    name = "NanoPi R2S";
    model = "R2S";
    manufacturer = "friendlyelec";
  };

  mkPingSensor = host: name: {
    platform = "ping";
    inherit name;
    inherit host;
    count = 2;
    scan_interval = 5;
  };
  mkMqttSensor = name: state_topic: unit_of_measurement: value_template: unique_id: device: {
    inherit name device state_topic unit_of_measurement value_template unique_id;
  };

  mkCollectdSensor = name: host: topic: unit_of_measurement: value_template: device: {
    inherit name unit_of_measurement value_template device;
    state_topic = "collectd/${host}/${topic}";
    unicue_id = "collectd_${host}_${topic}";
  };
in {
  services.home-assistant.config = mkIf cfg.enable {
    mqtt.sensors = [
      (mkCollectdSensor "L1" "R2S" "load/load" "load" "{{ value.split(':')[1] | float }}" deviceR2S)
    ];
  };
}
