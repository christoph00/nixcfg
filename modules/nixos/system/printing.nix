{
  pkgs,
  config,
  lib,
  self',
  ...
}: {
  config = lib.mkIf config.nos.printing {
    services.printing = {
      enable = true;
      drivers = [pkgs.gutenprint self'.packages.xr6515dn];
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
