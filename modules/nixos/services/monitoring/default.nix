{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.monitoring;
in {
  options.chr.services.monitoring = with types; {
    enable = mkBoolOpt true "Enable monitoring Service.";
    mqttHost = mkOption {
      type = types.str;
      default = "127.0.0.1:3322";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.chr.dunnart];
  };
}
