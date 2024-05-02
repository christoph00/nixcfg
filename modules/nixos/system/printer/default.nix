{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.printer;
in
{
  options.chr.system.printer = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to configure printer.";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        chr.xr6515dn
        gutenprint
      ];
    };
    hardware.printers.ensurePrinters = [
      {
        name = "Xerox_WorkCentre_6515DN";
        model = "xerox-workcentre-6515DN/xr6515dn.ppd";
        ppdOptions = {
          Duplex = "DuplexNoTumble";
          PageSize = "A4";
        };
        deviceUri = "ipps://192.168.2.110";
      }
    ];
  };
}
