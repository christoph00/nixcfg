{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.ebusd;
in {
  options.chr.services.ebusd = with types; {
    enable = mkBoolOpt config.chr.services.smart-home "Enable eBUSd Service.";
  };
  config =
    mkIf cfg.enable {
    };
}
