{...}: {
  services.home-assistant.config.sensor = [
    {
      platform = "netdata";
      name = "futro";
      resources = {
        load = {
          data_group = "system.load";
          element = "load15";
          icon = "mdi:chip";
        };
        data-ssd_avail = {
          data_group = "disk_space._media_data-ssd";
          element = "avail";
        };
        data-ssd_used = {
          data_group = "disk_space._media_data-ssd";
          element = "used";
        };
        data-hdd_avail = {
          data_group = "disk_space._media_data-hdd";
          element = "avail";
        };
        data-hdd_used = {
          data_group = "disk_space._media_data-hdd";
          element = "used";
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
