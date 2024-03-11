{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.z2m;
in {
  options.chr.services.z2m = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable zigbee2mqtt Service.";
  };
  config = mkIf cfg.enable {
    services.zigbee2mqtt = {
      enable = true;
      dataDir = "${config.chr.system.persist.stateDir}/z2m";
      settings = {
        homeassistant = true;
        permit_join = true;
        serial = {
          port = "/dev/ttyACM0";
        };
        mqtt.server = "mqtt://localhost:1883";
        frontend = {
          enable = true;
          port = 3080;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [3080];
  };
}
