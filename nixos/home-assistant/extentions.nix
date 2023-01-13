{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  mini-graph-card = "${pkgs.ha-lovelace-mini-graph-card}/ha-lovelace-mini-graph-card.js";
  better-thermostat-ui-card = "${pkgs.ha-lovelace-better-thermostat-ui-card}/ha-lovelace-better-thermostat-ui-card.js";
in {
  systemd.tmpfiles.rules = [
    # "d /nix/persist/hass/www 0755 hass hass"
    # "L /nix/persist/hass/www/valetudo-map-card.js - - - - ${valetudo-map-card}"
    # "L /nix/persist/hass/www/mini-media-player-bundle.js - - - - ${miniMediaPlayerCard}"
    # "L /nix/persist/hass/www/better-thermostat-ui-card.js - - - - ${better-thermostat-card}"

    "d /nix/persist/hass/custom_components 0755 hass hass"
    "L /nix/persist/hass/custom_components/ble_monitor - - - - ${pkgs.ha-components-ble-monitor}/ble_monitor"
    "L /nix/persist/hass/custom_components/better_thermostat - - - - ${pkgs.ha-components-better-thermostat}/better_thermostat"
  ];

  services.nginx.virtualHosts.hass = {
    locations."= /local/mini-mini-graph-card.js" = {
      alias = mini-graph-card;
    };
    locations."= /local/better-thermostat-ui-card.js" = {
      alias = better-thermostat-ui-card;
    };
  };

  ## Custom HA modules
  ##system.activationScripts.hassLovelaceModules = ''
  ##  cp --remove-destination ${valetudoMapCard}/valetudo-map-card.js /storage/home-assistant/www/valetudo-map-card.js
  ##  cp --remove-destination ${miniMediaPlayerCard} /storage/home-assistant/www/mini-media-player-bundle.js
  ##'';

  services.home-assistant.config.lovelace.resources = [
    {
      url = "/local/mini-graph-card.js?v=${builtins.hashFile "md5" mini-graph-card}";
      type = "module";
    }
    {
      url = "/local/better-thermostat-ui-card.js?v=${builtins.hashFile "md5" better-thermostat-ui-card}";
      type = "module";
    }
  ];
}
