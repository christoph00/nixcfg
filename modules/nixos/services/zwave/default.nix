{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.zwave;
in {
  options.chr.services.zwave = with types; {
    enable = mkBoolOpt false "Enable zwave Service.";
  };
  config = mkIf cfg.enable {
    services.zwave-js = {
      enable = true;
      port = 3090;
      serialPort = "/dev/ttyACM0";
      secretsConfigFile = config.age.secrets.zwave-js-keys.path;
    };

    age.secrets.zwave-js-keys.file = ../../../../secrets/zwave-js-keys.json;
  };
}
