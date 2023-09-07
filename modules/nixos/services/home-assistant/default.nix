{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.nos.services.home-assistant.enable {
    users.users.hass = {
      extraGroups = ["dialout"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower"
      ];
    };
    hardware.bluetooth.enable = true;

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
          #  internal_url = "http://futro.speedport.ip:8123";
          packages = "!include_dir_named pkgs";
        };
        default_config = {};
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
        zha = {
          enable_quirks = true;
          custom_quirks_path = "${config.services.home-assistant.configDir}/zha_quirks/";
          device_config = {
            "a4:c1:38:35:dd:d5:77:cc-1".type = "switch";
            "a4:c1:38:35:dd:d5:77:cc-2".type = "switch";
            "a4:c1:38:35:dd:d5:77:cc-3".type = "switch";
            "a4:c1:38:35:dd:d5:77:cc-4".type = "switch";
            "a4:c1:38:35:dd:d5:77:cc-5".type = "switch";
          };
        };
        #zha_toolkit = {};
        # ebusd = {
        #   host = "127.0.0.1";
        #   circuit = "basv0";
        # };
        ssdp = {};
        mqtt = {};
        dhcp = {};
        conversation = {};
        google_assistant = {
          project_id = "!secret google_projectid";
          service_account = "!include serviceaccount.json";
          report_state = true;
          exposed_domains = ["switch" "light"];
        };
        #lovelace.mode = "yaml";
        switch = [
          {
            name = "Tower";
            platform = "wake_on_lan";
            mac = "d0:50:99:82:42:04";
            #host = "tower.lan.net.r505.de";
            turn_off = {
              service = "shell_command.suspend_host";
              data.host = "tower.lan";
            };
          }
        ];
      };
      extraPackages = python3Packages:
        with pkgs.python3Packages; [
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
          #psycopg2
          google-api-core
          protobuf
          pymetno
          pyxiaomigateway
          pyiqvia
          pyipp
          wyoming
          #wyoming-piper
          androidtvremote2
          # faster-whisper
          androidtv
          pyebus
        ];
      extraComponents = [
        "caldav"
        "bluetooth"
        "calendar"
        "camera"
        "open_meteo"
        "adguard"
        "speedtestdotnet"
        "cups"
        "device_sun_light_trigger"
        "esphome"
        "frontend"
        "html5"
        "wyoming"
        "http"
        #"hyperion"
        "assist_pipeline"
        "jellyfin"
        "androidtv"
        "androidtv_remote"
        "openai_conversation"
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
        "ipp"
        "met"
        "ping"
        "snmp"
        "google"
        "spotify"
        #"python_script"
      ];
    };

    age.secrets.ha-secrets = {
      file = ../../../../secrets/ha-secrets.yaml;
      path = "/nix/persist/hass/secrets.yaml";
      owner = "hass";
      group = "hass";
    };

    age.secrets.ha-serviceaccount = {
      file = ../../../../secrets/ha-serviceaccount;
      path = "/nix/persist/hass/serviceaccount.json";
      owner = "hass";
      group = "hass";
    };

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

    # systemd.services.ebusd = {
    #   description = "ebusd";
    #   wantedBy = ["multi-user.target"];

    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.ebusd}/usr/bin/ebusd -f --scanconfig -d ens:ebus.speedport.ip:9999 --mqtthost futro.speedport.ip --mqttport 1883 --mqttvar=filter-direction=r|u|^w --mqttint=${pkgs.ebusd}/etc/ebusd/mqtt-hassio.cfg --mqttjson --configlang=de ";
    #   };
    # };
  };
}
