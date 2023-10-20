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
  haDir = config.services.home-assistant.configDir;

  mushroom = "${pkgs.chr.ha-lovelace-mushroom}/mushroom.js";
  bubble = "${pkgs.chr.ha-lovelace-bubble}/bubble-card.js";
  card-mod = "${pkgs.chr.ha-lovelace-card-mod}/card-mod.js";
in {
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      #"d ${haDir} 0755 hass hass"
      # "C /nix/persist/hass/www/vacuum-card.js 0755 hass hass - ${vacuum-card}"
      # "C /nix/persist/hass/www/button-card.js 0755 hass hass - ${button-card}"
      # "C /nix/persist/hass/www/layout-card.js 0755 hass hass - ${layout-card}"

      # "C /nix/persist/hass/www/mini-graph-card.js 0755 hass hass - ${mini-graph-card}"
      # "C /nix/persist/hass/www/better-thermostat-ui-card.js 0755 hass hass - ${better-thermostat-ui-card}"
      #"C ${haDir}/www/mushroom.js 0755 hass hass - ${mushroom}"
      #"C ${haDir}/www/bubble-card.js 0755 hass hass - ${bubble}"
      #"C ${haDir}/www/card-mod.js 0755 hass hass - ${card-mod}"
      "L+ ${haDir}/www - - - - ${cfg.linkfarm "www" [
        {
          name = "mushroom.js";
          path = mushroom;
        }
        {
          name = "bubble-card.js";
          path = bubble;
        }
        {
          name = "card-mod.js";
          path = card-mod;
        }
      ]}"

      "d /nix/persist/hass/custom_components 0755 hass hass"
      "L /nix/persist/hass/custom_components/better_thermostat - - - - ${pkgs.chr.ha-better-thermostat}/better_thermostat"
      #  "L /nix/persist/hass/custom_components/zha_toolkit - - - - ${pkgs.ha-component-zha-toolkit}/zha_toolkit"
    ];
  };
}
