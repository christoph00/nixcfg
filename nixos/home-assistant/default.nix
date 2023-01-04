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
    ./systemmonitor.nix
    ./webserver.nix
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    configDir = "/nix/persist/hass";
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 52;
        unit_system = "metric";
        temperature_unit = "C";
        external_url = "https://ha.r505.de";
        internal_url = "https://ha.net.r505.de";
      };
      default_config = {};
      config = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = ["::1" "127.0.0.1"];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      automation = {};
      frontend = {};
      mobile_app = {};
      discovery = {};
      zeroconf = {};
      #zha = {};
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
      feedreader.urls = ["https://nixos.org/blogs.xml"];
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

  # age.secrets.ha-secrets = {
  #   file = ../../../secrets/ha-secrets.yaml;
  #   path = "/nix/persist/hass/secrets.yaml";
  #   owner = "hass";
  #   group = "hass";
  # };

  # age.secrets.ha-serviceaccount = {
  #   file = ../../../secrets/ha-serviceaccount;
  #   path = "/nix/persist/hass/serviceaccount.json";
  #   owner = "hass";
  #   group = "hass";
  # };
}
