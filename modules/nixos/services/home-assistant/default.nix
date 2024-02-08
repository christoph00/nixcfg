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
in {
  options.chr.services.home-assistant = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable Home-Assistant Service.";
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "ha.r505.de";
    };
  };
  config = lib.mkIf cfg.enable {
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
      package =
        (pkgs.home-assistant.override {
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
              gtts
              psycopg2
              google-api-core
              pyebus
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
              hatasmota
              kegtron-ble
            ];
        })
        .overrideAttrs (oldAttrs: {doInstallCheck = false;});
      openFirewall = true;
      configDir = "${config.chr.system.persist.stateDir}/hass";
      customComponents = with pkgs; [
        pkgs.home-assistant-custom-components.prometheus_sensor
        chr.ha-better-thermostat
        chr.ha-home-llm
        chr.ha-ollama
      ];
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        mini-graph-card
        mini-media-player
      ];
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
          #internal_url = "https://ha.net.r505.de";
          packages = "!include_dir_named pkgs";
          #customize.zone.home.radius = 20;
        };
        default_config = {};
        device_tracker = [
          # {
          #   platform = "bluetooth_le_tracker";
          # }
          # {
          #   platform = "bluetooth_tracker";
          # }
          {
            platform = "luci";
            host = "192.168.2.1";
            username = "root";
            password = "!secret router_pass";
            ssl = true;
            verify_ssl = false;
          }
        ];
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
        dhcp = {};
        ssdp = {};
        zeroconf = {};
        bthome = {};
        media_extractor = {};
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
        # ebusd = mkIf config.chr.services.ebusd.enable {
        #   host = "127.0.0.1";
        #   circuit = "basv0";
        # };
        ssdp = {};
        mqtt = {
          climate = [
            {
              name = "Heizung";
              max_temp = 25;
              min_temp = 12;
              precision = 0.1;
              temp_step = 0.5;
              modes = ["auto" "heat" "off"];
              # Quite an ugly regex workaround due to 0 not being findable...
              mode_state_template = ''
                {% set values = { 'auto':'auto', 'day':'heat', 'off':'off'} %}
                {% set v = value | regex_findall_index( '"value"\s?:\s?"(.*)"')  %}
                {{ values[v] if v in values.keys() else 'auto' }}
              '';
              mode_state_topic = "ebusd/basv/z1OpMode";
              mode_command_template = ''
                {% set values = { 'auto':'auto', 'heat':'day', 'off':'off'} %}
                {{ values[value] if value in values.keys() else 'off' }}
              '';
              mode_command_topic = "ebusd/basv/z1OpMode/set";
              temperature_state_topic = "ebusd/basv/z1ActualRoomTempDesired";
              temperature_state_template = "{{ value_json.tempv.value }}";
              temperature_high_state_topic = "ebusd/basv/z1DayTemp";
              temperature_high_state_template = "{{ value_json.tempv.value }}";
              temperature_high_command_topic = "ebusd/basv/z1DayTemp/set";
              temperature_high_command_template = ''
                {{ value }}
              '';
              current_temperature_topic = "ebusd/basv/z1RoomTemp";
              current_temperature_template = "{{ value_json.tempv.value }}";
              temperature_unit = "C";
            }
            # {
            #   name = "Warmwasser";
            #   max_temp = 90;
            #   min_temp = 0;
            #   precision = 0.1;
            #   temp_step = 0.5;
            #   # unfortunately mapping is not correct (Yet)
            #   modes = ["off" "on" "auto" "party" "load" "holiday"];
            #   mode_state_template = ''
            #     {% set values = { 0:'off', 1:'on',  2:'auto', 3:'autosunday', 4:'party', 5: 'load', 7: 'holiday'} %}
            #     {{ values[value] if value in values.keys() else 'auto' }}
            #   '';
            #   mode_state_topic = "ebusd/bai/HwcOPMode";
            #   mode_command_template = ''
            #     {% set values = { 'off':0, 'on':1,  'auto':2, 'autosunday':3, 'party':4, 'load':5, 'holiday':7} %}
            #     {{ values[value] if value in values.keys() else 2 }}
            #   '';
            #   mode_command_topic = "ebusd/bai/HwcOPMode/set";
            #   temperature_state_topic = "ebusd/bai/HwcTempDesired";
            #   temperature_state_template = "{{ value_json.temp1.value }}";
            #   current_temperature_topic = "ebusd/bai/DisplayedHwcStorageTemp";
            #   current_temperature_template = "{{ value_json.temp1.value }}";
            #   temperature_unit = "C";
            # }
          ];
        };
        tasmota = {};
        dhcp = {};
        conversation = {};
        ffmpeg = {
          ffmpeg_bin = "${pkgs.ffmpeg}/bin/ffmpeg";
        };
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
              data.host = "tower.lan.r505.de";
            };
          }
        ];
      };
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
        "radio_browser"
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
        "bluetooth_tracker"
        "bluetooth_le_tracker"
        "bthome"
        "bluetooth_adapters"
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

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "ha.r505.de" = "http://127.0.0.1:8123";
      };
    };
  };
}
