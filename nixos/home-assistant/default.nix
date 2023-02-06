{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    #./postgres.nix
    ./extentions.nix
    #./systemmonitor.nix
    #./webserver.nix
  ];

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant.overrideAttrs (old: {
      doCheck = false;
      checkPhase = ":";
      installCheckPhase = ":";
    });
    openFirewall = true;
    configDir = "/nix/persist/hass";
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 52;
        country = "DE";
        unit_system = "metric";
        time_zone = "Europe/Berlin";
        temperature_unit = "C";
        external_url = "https://ha.r505.de";
        internal_url = "https://ha.net.r505.de";
      };
      default_config = {};
      config = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = ["::1" "127.0.0.1" "100.0.0.0/8"];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      automation = {};
      frontend = {};
      mobile_app = {};
      discovery = {};
      zeroconf = {};
      zha = {};
      ssdp = {};
      mqtt = {};
      google_assistant = {
        project_id = "!secret google_projectid";
        service_account = "!include serviceaccount.json";
        report_state = true;
        exposed_domains = ["switch" "light"];
      };

      # ebusd = {
      #   host = "127.0.0.1";
      #   circuit = "700";
      # };
      lovelace.mode = "yaml";
      sensor = [
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
              data_group = "net.enp3s0f0";
              element = "received";
            };
            network_upload = {
              data_group = "net.enp3s0f0";
              element = "sent";
              invert = true;
            };
          };
        }
      ];
    };
    extraPackages = python3Packages:
      with python3Packages; [
        aiodiscover
        aiogithubapi
        scapy
        securetar
        kegtron-ble
        aioblescan
        janus
        bluepy
        pybluez
        ifaddr
        zeroconf
        psycopg2
      ];
    extraComponents = [
      "caldav"
      "bluetooth"
      "calendar"
      "camera"
      "open_meteo"
      #"adguard"
      "speedtestdotnet"
      "cups"
      "device_sun_light_trigger"
      "esphome"
      "frontend"
      "html5"
      "http"
      #"hyperion"
      "jellyfin"
      "androidtv"
      "lovelace"
      "mobile_app"
      "nzbget"
      "ubus"
      "wake_on_lan"
      "cast"
      #  "wled"
      "xiaomi_miio"
      "xiaomi_ble"
      "openweathermap"
      "weather"
      "rest"
    ];
    # configWritable = true; # doesn't work atm
  };

  age.secrets.ha-secrets = {
    file = ../../secrets/ha-secrets.yaml;
    path = "/nix/persist/hass/secrets.yaml";
    owner = "hass";
    group = "hass";
  };

  age.secrets.ha-serviceaccount = {
    file = ../../secrets/ha-serviceaccount;
    path = "/nix/persist/hass/serviceaccount.json";
    owner = "hass";
    group = "hass";
  };
}
