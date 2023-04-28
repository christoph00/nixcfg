{pkgs, ...}: {
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = ["pattern readwrite #"];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
  users.users.zigbee2mqtt.extraGroups = ["dialout"];
  services.zigbee2mqtt.enable = true;
  services.zigbee2mqtt.settings = {
    homeassistant = true;
    frontend = {
      port = 8030;
    };
    mqtt.server = "mqtt://localhost:1883";
    permit_join = true;
    serial = {
      #port = "/dev/ttyACM0";
      adapter = "ezsp";
    };
    advanced = {
      log_output = ["console"];
      legacy_api = false;
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/zigbee2mqtt"
    ];
  };
}
