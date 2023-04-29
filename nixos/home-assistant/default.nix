{pkgs, ...}: {
  imports = [
    ./postgres.nix
    ./extentions.nix
    ./systemmonitor.nix
    ./commands.nix
    ./network_sensors.nix
    #./netdata.nix
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
        packages = "!include_dir_named pkgs";
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
      lovelace.mode = "yaml";
      switch = [
        {
          name = "Tower";
          platform = "wake_on_lan";
          mac = "d0:50:99:82:42:04";
          #host = "tower.lan.net.r505.de";
          turn_off = {
            service = "shell_command.suspend_host";
            data.host = "tower.lan.net.r505.de";
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
        google-api-core
        protobuf
        pymetno
      ];
    extraComponents = [
      "caldav"
      "bluetooth"
      "calendar"
      "camera"
      "androidtv"
      "open_meteo"
      "adguard"
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
      "weather"
      "rest"
      "ping"
      "snmp"
      "google"
      "spotify"
      "python_script"
    ];
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
