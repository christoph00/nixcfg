{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [gutenprint xr6515dn];
  };
  hardware.printers.ensurePrinters = [
    {
      name = "Xerox_WorkCentre_6515DN";
      model = "xerox-workcentre-6515DN/xr6515dn.ppd";
      ppdOptions = {
        Duplex = "DuplexNoTumble";
        PageSize = "A4";
      };
      deviceUri = "ipps://xerox.lan.net.r505.de";
    }
  ];
}
