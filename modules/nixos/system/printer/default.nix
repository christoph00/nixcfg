{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.printer;
in {
  options.chr.system.printer = with types; {
    enable =
      mkBoolOpt false "Whether or not to configure printer.";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [chr.xr6515dn];
    };
  };
}
