{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.mqtt;
in {
  options.chr.services.mqtt = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable mqtt Service.";
  };
  config = mkIf cfg.enable {
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
    networking.firewall.allowedTCPPorts = [1883];
    environment.systemPackages = [pkgs.mqttui];
  };
}
