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
      package = pkgs.home-assistant.overrideAttrs (old: {
        doCheck = false;
        checkPhase = ":";
        installCheckPhase = ":";
      });
      openFirewall = true;
      configDir = "${config.chr.system.persist.stateDir}/hass";
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
        mqtt = {};
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

    age.secrets.cf-tunnel = {
      file = ../../../../secrets/cf-tunnel-${config.networking.hostName};
      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;
    };

    boot.kernel.sysctl."net.core.rmem_max" = lib.mkDefault 2500000;
    services.cloudflared.enable = true;
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      default = "http_status:404";
      credentialsFile = config.age.secrets.cf-tunnel.path;
      ingress = {
        "ha.r505.de" = "http://127.0.0.1:8123";
      };
    };
  };
}
