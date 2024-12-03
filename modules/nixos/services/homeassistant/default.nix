{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.homeassistant;
  inherit (pkgs.writers) writeYAML;

in

{

  options.internal.services.homeassistant = {
    enable = mkBoolOpt config.internal.isSmartHome "Enable Homeassistant.";
  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [
      {
        directory = "/var/lib/hass";
        user = "hass";
        group = "hass";
      }
    ];

    users.extraUsers."hass".extraGroups = [ "dialout" ];

    security.doas.extraRules = [
      {
        users = [ "hass" ];
        cmd = "systemctl";
        args = [ "status" "stop" "start" "restart" "reboot" ];
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

    services.mosquitto = {
      enable = true;
      listeners = [{
        settings.allow_anonymous = true;
        acl = [ "topic readwrite #" ];
        users = {
          ha = { acl = [ "readwrite #" ]; password = "ha"; };
          robot = { acl = [ "readwrite #" ]; password = "robot"; };
        };
      }];
    };

    services.home-assistant =
      let
        package = pkgs.home-assistant.override {
          extraPackages =
            ps: with ps; [
              defusedxml
              python-miio
              netdisco
              async-upnp-client
              paho-mqtt
              withings-api
              withings-sync
              aiowithings
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
              netmiko
            ];
        };
      in
      {
        enable = true;
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
              event_types = [
                "call_service"
              ];
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
        customComponents = (with pkgs.home-assistant-custom-components; [
          better_thermostat
          prometheus_sensor
          spook
          waste_collection_schedule
          xiaomi_miot
          bodymiscale
        ]) ++ (with pkgs; [
          # home-assistant-bermuda
          # home-assistant-browser-mod
          # home-assistant-music-assistant
          # home-assistant-pirate-weather
          # home-assistant-spotcast
          # home-assistant-var
        ]);

        customLovelaceModules =
          (with pkgs.home-assistant-custom-lovelace-modules; [
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
          ]) ++ (with pkgs; [
            internal.bubble-card
            # home-assistant-lovelace-card-tools
            # home-assistant-lovelace-config-template-card
            # home-assistant-lovelace-custom-brand-icons
            # home-assistant-lovelace-grocy-chores-card
            # home-assistant-lovelace-layout-card
            # home-assistant-lovelace-waze-travel-time
          ]);
        extraComponents = [
          "caldav"
          "bluetooth"
          #"cloud"
          "calendar"
          "camera"
          "open_meteo"
          #"adguard"
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
          #"hyperion"
          "assist_pipeline"
          "jellyfin"
          "androidtv"
          "androidtv_remote"
          #"openai_conversation"
          "lovelace"
          "mobile_app"
          #"nzbget"
          #"ubus"
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

          "zwave_js"

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
  };

}
