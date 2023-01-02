{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  valetudo-map-card = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/TheLastProject/lovelace-valetudo-map-card/master/valetudo-map-card.js";
    sha256 = "0xkfvphd27k7wdl2aq13d77xci8hyhpjacc1nhgxyg1gv2zxwrpg";
  };
  miniMediaPlayerCard = builtins.fetchurl {
    url = "https://github.com/kalkih/mini-media-player/releases/download/v1.12.0/mini-media-player-bundle.js";
    sha256 = "170x5x4x0lv71k6lxl8hpcy6q9sqds4nc60njksc5dlhcnk4408h";
  };
  better-thermostat-card = builtins.fetchurl {
    url = "https://github.com/KartoffelToby/better-thermostat-ui-card/releases/download/0.8.2/better-thermostat-ui-card.js";
    sha256 = "1k83d98qawrwqjblxgz25nxgq73jbhshvbgm0hiiqi4cm33yhf2d";
  };
  vacuum-card = builtins.fetchurl {
    url = "https://github.com/denysdovhan/vacuum-card/releases/download/v2.6.3/vacuum-card.js";
    sha256 = "1yy9bj6dpaq3h9pacwjnz1jywg70m6njpf4968abqfiyfnvs7699";
  };

  ble_monitor = builtins.fetchTarball {
    url = "https://github.com/custom-components/ble_monitor/archive/refs/tags/10.5.3.tar.gz";
    sha256 = "0v79zkkb0av5ymhch76xkpcclg54nfvasgkfgyvjv58g68qbqhq8";
  };
  better_thermostat = builtins.fetchTarball {
    url = "https://github.com/KartoffelToby/better_thermostat/archive/refs/tags/1.0.0-beta39.tar.gz";
    sha256 = "0pzjz6xf2jalpmjw67h1njf56v96l91k3x0ahyxyni1acb8af1fa";
  };
in {
  systemd.tmpfiles.rules = [
    # "d /nix/persist/hass/www 0755 hass hass"
    # "L /nix/persist/hass/www/valetudo-map-card.js - - - - ${valetudo-map-card}"
    # "L /nix/persist/hass/www/mini-media-player-bundle.js - - - - ${miniMediaPlayerCard}"
    # "L /nix/persist/hass/www/better-thermostat-ui-card.js - - - - ${better-thermostat-card}"

    "d /nix/persist/hass/custom_components 0755 hass hass"
    "L /nix/persist/hass/custom_components/ble_monitor - - - - ${ble_monitor}/custom_components/ble_monitor"
    "L /nix/persist/hass/custom_components/better_thermostat - - - - ${better_thermostat}/custom_components/better_thermostat"
  ];

  services.nginx.virtualHosts.hass = {
    locations."= /local/mini-media-player-bundle.js" = {
      alias = miniMediaPlayerCard;
    };
    locations."= /local/valetudo-map-card.js" = {
      alias = valetudo-map-card;
    };
    locations."= /local/better-thermostat-ui-card.js" = {
      alias = better-thermostat-card;
    };
    locations."= /local/vacuum-card.js" = {
      alias = vacuum-card;
    };
  };

  ## Custom HA modules
  ##system.activationScripts.hassLovelaceModules = ''
  ##  cp --remove-destination ${valetudoMapCard}/valetudo-map-card.js /storage/home-assistant/www/valetudo-map-card.js
  ##  cp --remove-destination ${miniMediaPlayerCard} /storage/home-assistant/www/mini-media-player-bundle.js
  ##'';

  services.home-assistant.config.lovelace.resources = [
    {
      url = "/local/valetudo-map-card.js?v=${builtins.hashFile "md5" valetudo-map-card}";
      type = "module";
    }
    {
      url = "/local/mini-media-player-bundle.js?v=${builtins.hashFile "md5" miniMediaPlayerCard}";
      type = "module";
    }
    {
      url = "/local/better-thermostat-ui-card.js?v=${builtins.hashFile "md5" better-thermostat-card}";
      type = "module";
    }
    {
      url = "/local/vacuum-card.js?v=${builtins.hashFile "md5" vacuum-card}";
      type = "module";
    }
  ];
}
