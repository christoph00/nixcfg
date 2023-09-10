{
  lib,
  config,
  ...
}: {
  services.home-assistant.config.sensor = lib.mkIf config.nos.services.home-assistant.enable [
    {
      platform = "netdata";
      name = "router";
      resources = {
        load = {
          data_group = "system.load";
          element = "load15";
          icon = "mdi:chip";
        };
        temperature = {
          data_group = "sensors.k10temp-pci-00c3_temperature";
          element = "temp1";
          icon = "mdi:thermometer-low";
        };
        network_download = {
          data_group = "net.pppoe-wan";
          element = "received";
        };
        network_upload = {
          data_group = "net.pppoe-wan";
          element = "sent";
          invert = true;
        };
      };
    }
    # {
    #   platform = "netdata";
    #   name = "tower";
    #   host = "tower.lan.net.r505.de";
    #   resources = {
    #     load5 = {
    #       data_group = "system.load";
    #       element = "load5";
    #     };
    #   };
    # }
  ];
}
