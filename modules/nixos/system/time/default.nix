{ options, config, pkgs, lib, ... }:

with lib;
with lib.chr;
let cfg = config.chr.system.time;
in
{
  options.chr.system.time = with types; {
    enable =
      mkBoolOpt false "Whether or not to configure timezone information.";
  };

  config = mkIf cfg.enable { time.timeZone = "Europe/Berlin"; };
}