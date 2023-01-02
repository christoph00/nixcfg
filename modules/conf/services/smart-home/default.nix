{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.conf.services.smart-home;
in {
  options = with lib; {
    enable = mkEnableOption "Smart Home";
  };

  config = lib.mkIf cfg.enable {
    imports = [../home-assistant];

    networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443];
    networking.firewall.allowedUDPPorts = [53];

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      statusPage = true;
      enableReload = true;
      commonHttpConfig = ''
        set_real_ip_from 103.21.244.0/22;
        set_real_ip_from 103.22.200.0/22;
        set_real_ip_from 103.31.4.0/22;
        set_real_ip_from 104.16.0.0/13;
        set_real_ip_from 104.24.0.0/14;
        set_real_ip_from 108.162.192.0/18;
        set_real_ip_from 131.0.72.0/22;
        set_real_ip_from 141.101.64.0/18;
        set_real_ip_from 162.158.0.0/15;
        set_real_ip_from 172.64.0.0/13;
        set_real_ip_from 173.245.48.0/20;
        set_real_ip_from 188.114.96.0/20;
        set_real_ip_from 190.93.240.0/20;
        set_real_ip_from 197.234.240.0/22;
        set_real_ip_from 198.41.128.0/17;
        set_real_ip_from 2400:cb00::/32;
        set_real_ip_from 2606:4700::/32;
        set_real_ip_from 2803:f800::/32;
        set_real_ip_from 2405:b500::/32;
        set_real_ip_from 2405:8100::/32;
        set_real_ip_from 2c0f:f248::/32;
        set_real_ip_from 2a06:98c0::/29;
        real_ip_header CF-Connecting-IP;
      '';
    };
    users.users.nginx.extraGroups = ["acme"];

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

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "christoph@asche.co";
      };
      certs."net.r505.de" = {
        domain = "*.net.r505.de";
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.cf-acme.path;
        dnsResolver = "1.1.1.1:53";
      };
    };

    users.users.zigbee2mqtt.extraGroups = ["dialout"];
    services.zigbee2mqtt.enable = true;
    services.zigbee2mqtt.settings = {
      homeassistant = true;
      frontend = {
        port = 8030;
      };
      mqtt.server = "mqtt://localhost:1883";
      permit_join = true;
      serial = {
        #port = "/dev/ttyACM0";
        adapter = "ezsp";
      };
      advanced = {
        log_output = ["console"];
        legacy_api = false;
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/lib/home-assistant"
        "/var/lib/zigbee2mqtt"
        {
          directory = "/var/lib/hass";
          user = "hass";
          group = "hass";
        }
      ];
    };
  };
}
