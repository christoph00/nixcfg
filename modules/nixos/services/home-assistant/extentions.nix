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
  button-card = "${pkgs.ha-lovelace-button-card}/ha-lovelace-button-card.js";
  layout-card = "${pkgs.ha-lovelace-layout-card}/ha-lovelace-layout-card.js";

  mushroom = "${pkgs.ha-lovelace-mushroom}/ha-lovelace-mushroom.js";
in {
  services.home-assistant.config.default_config.whitelist_external_dirs = ["/nix/persist/hass/www"];
  systemd.tmpfiles.rules = [
    "d /nix/persist/hass/www 0755 hass hass"
    "C /nix/persist/hass/www/vacuum-card.js 0755 hass hass - ${vacuum-card}"
    "C /nix/persist/hass/www/button-card.js 0755 hass hass - ${button-card}"
    "C /nix/persist/hass/www/layout-card.js 0755 hass hass - ${layout-card}"

    "C /nix/persist/hass/www/mini-graph-card.js 0755 hass hass - ${mini-graph-card}"
    "C /nix/persist/hass/www/better-thermostat-ui-card.js 0755 hass hass - ${better-thermostat-ui-card}"
    "C /nix/persist/hass/www/mushroom.js 0755 hass hass - ${mushroom}"

    "d /nix/persist/hass/custom_components 0755 hass hass"
    "L /nix/persist/hass/custom_components/better_thermostat - - - - ${pkgs.ha-component-better-thermostat}/better_thermostat"
    "L /nix/persist/hass/custom_components/zha_toolkit - - - - ${pkgs.ha-component-zha-toolkit}/zha_toolkit"
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
    {
      url = "/local/button-card.js?v=${builtins.hashFile "md5" button-card}";
      type = "module";
    }
    {
      url = "/local/layout-card.js?v=${builtins.hashFile "md5" layout-card}";
      type = "module";
    }
    {
      url = "/local/mushroom.js?v=${builtins.hashFile "md5" mushroom}";
      type = "module";
    }
  ];
}