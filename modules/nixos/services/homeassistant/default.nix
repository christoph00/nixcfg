{
  lib,
  pkgs,
  config,
  flake,
  ...
}:

with builtins;
with lib;
with flake.lib;

let
  cfg = config.services.home-assistant;

in
{

  imports = [
    # ./assist.nix
    # ./commands.nix
    # ./wyoming.nix
  ];

  config = mkIf cfg.enable {

    sys.state.directories = [
      "/var/lib/hass"
    ];

    users.extraUsers."hass".extraGroups = [ "dialout" ];

    security.doas.extraRules = [
      {
        users = [ "hass" ];
        cmd = "systemctl";
        args = [
          "status"
          "stop"
          "start"
          "restart"
          "reboot"
        ];
        runAs = "root";
        noPass = true;
      }
      {
        users = [ "hass" ];
        cmd = "nh";
        noPass = true;
        runAs = "root";
      }
    ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.nginx.virtualHosts."ha.r505.de" = {
      useACMEHost = "r505.de";
      forceSSL = true;
      kTLS = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };

    services.home-assistant =
      let
        package = perSystem.nixpkgs-unstable.home-assistant.override {
          extraPackages =
            ps: with ps; [
              defusedxml
              python-miio
              netdisco
              async-upnp-client
              paho-mqtt
              #withings-api
              #withings-sync
              #aiowithings
              python-otbr-api
              pyipp
              pysnmp
              qingping-ble
              xiaomi-ble
              pyxiaomigateway
              radios
              bluepy
              pybluez
              aioblescan
              grpcio-gcp

            ];
        };
      in
      {
        openFirewall = true;
        package = package.overrideAttrs (o: {
          doInstallCheck = false;
        });

        config = {
          homeassistant = {
            name = "Home";
            country = "DE";
            elevation = "51";
            unit_system = "metric";
            time_zone = "Europe/Berlin";
            external_url = "https://ha.r505.de";
            packages = "!include_dir_named pkgs";
          };
          http = {
            server_host = "0.0.0.0";
            server_port = 8123;
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
              "100.77.87.57" # oc1
              # "${config.network.subnets.vpn}"
            ];
          };
          mobile_app = { };
          frontend = { };
          history = { };
          config = { };
          tts = [
            {
              platform = "google_translate";
              service_name = "google_say";
            }
          ];
          dhcp = { };
          logbook = { };
          recorder = {
            commit_interval = 30;
            purge_keep_days = 7;
            exclude = {
              domains = [
                "automation"
                "updater"
              ];
              entity_globs = [
                "sensor.weather_*"
                "sensor.date_*"
              ];
              entities = [
                "sun.sun"
                "sensor.last_boot"
                "sensor.date"
                "sensor.time"
              ];
              event_types = [ "call_service" ];
            };
          };
          ffmpeg = {
            ffmpeg_bin = "${pkgs.ffmpeg}/bin/ffmpeg";
          };
          wake_on_lan = { };
          utility_meter = { };
          zha = {
            enable_quirks = true;
            zigpy_config.ota.ikea_provider = true;
            device_config = {
              "a4:c1:38:35:dd:d5:77:cc-1".type = "switch";
              "a4:c1:38:35:dd:d5:77:cc-2".type = "switch";
              "a4:c1:38:35:dd:d5:77:cc-3".type = "switch";
              "a4:c1:38:35:dd:d5:77:cc-4".type = "switch";
              "a4:c1:38:35:dd:d5:77:cc-5".type = "switch";
            };
          };
          lovelace.mode = "yaml";

          mqtt = {
            sensor = [
              {
                name = "Host Status";
                state_topic = "host/+/heartbeat";
                value_template = "{{ value_json.status }}";
                json_attributes_topic = "host/+/heartbeat";
              }
              {
                name = "Service Status";
                state_topic = "host/+/service/+";
                value_template = "{{ value_json.status }}";
                json_attributes_topic = "host/+/service/+";
              }
            ];
          };

          bluetooth = { };
          system_health = { };
          "automation ui" = "!include automations.yaml";
          "scene ui" = "!include scenes.yaml";
          "script ui" = "!include scripts.yaml";
          google_assistant = {
            project_id = "!secret google_projectid";
            service_account = "!include serviceaccount.json";
            report_state = true;
            exposed_domains = [
              "switch"
              "light"
            ];
          };

        };
        lovelaceConfig = {
          title = "Hidden";
          show_in_sidebar = false;
          require_admin = true;
        };
        customComponents = (
          with pkgs.home-assistant-custom-components;
          [
            better_thermostat
            prometheus_sensor
            spook
            waste_collection_schedule
            xiaomi_miot
            bodymiscale
          ]
        );

        customLovelaceModules = (
          with pkgs.home-assistant-custom-lovelace-modules;
          [
            apexcharts-card
            atomic-calendar-revive
            button-card
            card-mod
            decluttering-card
            hourly-weather
            light-entity-card
            mini-graph-card
            mini-media-player
            multiple-entity-row
            mushroom
            template-entity-row
            universal-remote-card
            bubble-card
          ]
        );
        extraComponents = [
          "caldav"
          "bluetooth"
          #"cloud"
          "calendar"
          "camera"
          "open_meteo"
          "adguard"
          "speedtestdotnet"
          "google_travel_time"
          "cups"
          "device_sun_light_trigger"
          "esphome"
          "frontend"
          "html5"
          "wyoming"
          "cloudflare"
          "http"
          "google_generative_ai_conversation"
          "tailscale"
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
          "isal"

          "webdav"

          "zwave_js"
          "cookidoo"
          "file"
          "media_extractor"
          "youtube"
          "google_generative_ai_conversation"
          "openai_conversation"

          "cpuspeed"
          "fail2ban"
          "hddtemp"

          "python_script"
          "bluetooth_tracker"
          "bluetooth_le_tracker"
          "bthome"
          "bluetooth_adapters"
        ];
      };

    systemd.services.home-assistant.environment = {
      OPENAI_BASE_URL = "https://openrouter.ai/api/v1";
    };
  };

}
