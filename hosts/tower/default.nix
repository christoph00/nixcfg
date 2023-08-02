{...}: {
  nos = {
    type = "desktop";
    fs = {
      persist = true;
      mainDisk = "/dev/disk-by/label/NIXOS";
      efiDisk = "/dev/nvme0n1p1";
    };
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];
}
