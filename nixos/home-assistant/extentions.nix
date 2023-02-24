{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  mini-graph-card = "${pkgs.ha-lovelace-mini-graph-card}/ha-lovelace-mini-graph-card.js";
  better-thermostat-ui-card = "${pkgs.ha-lovelace-better-thermostat-ui-card}/ha-lovelace-better-thermostat-ui-card.js";
  vacuum-card = "${pkgs.ha-lovelace-vacuum-card}/ha-lovelace-vacuum-card.js";
in {
  services.home-assistant.config.default_config.whitelist_external_dirs = ["/nix/persist/hass/www"];
  systemd.tmpfiles.rules = [
    "d /nix/persist/hass/www 0755 hass hass"
    "C /nix/persist/hass/www/vacuum-card.js 0755 hass hass - ${vacuum-card}"
    "C /nix/persist/hass/www/mini-graph-card.js 0755 hass hass - ${mini-graph-card}"
    "C /nix/persist/hass/www/better-thermostat-ui-card.js 0755 hass hass - ${better-thermostat-ui-card}"

    "d /nix/persist/hass/custom_components 0755 hass hass"
    "L /nix/persist/hass/custom_components/ble_monitor - - - - ${pkgs.ha-component-ble-monitor}/ble_monitor"
    "L /nix/persist/hass/custom_components/better_thermostat - - - - ${pkgs.ha-component-better-thermostat}/better_thermostat"
    "L /nix/persist/hass/custom_components/promql - - - - ${pkgs.ha-component-promql}/promql"

  ];

  services.nginx.virtualHosts.hass = {
    locations."= /local/mini-mini-graph-card.js" = {
      alias = mini-graph-card;
    };
    locations."= /local/better-thermostat-ui-card.js" = {
      alias = better-thermostat-ui-card;
    };
    locations."= /local/vacuum-card.js" = {
      alias = vacuum-card;
    };
  };

  services.home-assistant.config.lovelace.resources = [
    {
      url = "/local/mini-graph-card.js?v=${builtins.hashFile "md5" mini-graph-card}";
      type = "module";
    }
    {
      url = "/local/better-thermostat-ui-card.js?v=${builtins.hashFile "md5" better-thermostat-ui-card}";
      type = "module";
    }
    {
      url = "/local/vacuum-card.js?v=${builtins.hashFile "md5" vacuum-card}";
      type = "module";
    }
  ];
}
