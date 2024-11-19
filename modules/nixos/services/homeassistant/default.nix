{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.homeassistant;

in

{

  options.internal.services.homeassistant = {
    enable = mkBoolOpt config.internal.isSmartHome "Enable Homeassistant.";
  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/hass" ];

    users.extraUsers."hass".extraGroups = [ "dialout" ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    age.secrets.ha-secrets = {
      file = ../../../../secrets/ha-secrets.age;
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = "hass";
      group = "hass";
    };

    age.secrets.ha-serviceaccount = {
      file = ../../../../secrets/ha-serviceaccount.age;
      path = "${config.services.home-assistant.configDir}/serviceaccount.json";
      owner = "hass";
      group = "hass";
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
          dhcp = { };
          ffmpeg = {
            ffmpeg_bin = "${pkgs.ffmpeg}/bin/ffmpeg";
          };
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
          system_health = { };
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
        extraComponents = [
          "caldav"
          "bluetooth"
          #"cloud"
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
          "wyoming"
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

          "zwave_js"

          "python_script"
          "bluetooth_tracker"
          "bluetooth_le_tracker"
          "bthome"
          "bluetooth_adapters"
        ];
      };
  };

}
