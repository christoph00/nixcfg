{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.services.home-assistant;
in
{
  services.home-assistant.config.sensor = mkIf cfg.enable [
    {
      platform = "prometheus_sensor";
      url = "http://air13.netbird.cloud:8428"; # TODO: fix hardcoded url
      queries = [
        {
          name = "Futro Load";
          expr = "node_load1{instance='futro'}";
          unit_of_measurement = "load";
          state_class = "measurement";
        }
      ];
    }
  ];
}
