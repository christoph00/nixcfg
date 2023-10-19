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
in {
  config = mkIf cfg.enable {
    services.home-assistant.config.default_config.whitelist_external_dirs = ["${haDir}/www"];
    systemd.tmpfiles.rules = [
      "d ${haDir} 0755 hass hass"
      # "C /nix/persist/hass/www/vacuum-card.js 0755 hass hass - ${vacuum-card}"
      # "C /nix/persist/hass/www/button-card.js 0755 hass hass - ${button-card}"
      # "C /nix/persist/hass/www/layout-card.js 0755 hass hass - ${layout-card}"

      # "C /nix/persist/hass/www/mini-graph-card.js 0755 hass hass - ${mini-graph-card}"
      # "C /nix/persist/hass/www/better-thermostat-ui-card.js 0755 hass hass - ${better-thermostat-ui-card}"
      "L ${haDir}/www/mushroom.js 0755 hass hass - ${mushroom}"

      #  "d /nix/persist/hass/custom_components 0755 hass hass"
      #  "L /nix/persist/hass/custom_components/better_thermostat - - - - ${pkgs.ha-component-better-thermostat}/better_thermostat"
      #  "L /nix/persist/hass/custom_components/zha_toolkit - - - - ${pkgs.ha-component-zha-toolkit}/zha_toolkit"
    ];

    services.home-assistant.config.lovelace.resources = [
      {
        url = "/local/mushroom.js?v=${builtins.hashFile "md5" mushroom}";
        type = "module";
      }
    ];
  };
}
