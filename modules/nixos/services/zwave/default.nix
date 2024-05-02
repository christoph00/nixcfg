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
  cfg = config.chr.services.zwave;
in
{
  options.chr.services.zwave = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable zwave Service.";
  };
  config = mkIf cfg.enable {
    services.zwave-js = {
      enable = true;
      port = 3090;
      serialPort = "/dev/ttyACM1";
      secretsConfigFile = config.age.secrets.zwave-js-keys.path;
    };

    networking.firewall.allowedTCPPorts = [ 3090 ];

    age.secrets.zwave-js-keys = {
      file = ../../../../secrets/zwave-js-keys.json;
      mode = "444";
    };
  };
}
