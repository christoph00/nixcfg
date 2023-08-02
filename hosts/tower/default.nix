{...}: {
  nos = {
    type = "desktop";
    hw = {
      cpu = "intel";
      gpu = "amd";
    };
    fs = {
      persist = true;
      mainDisk = "/dev/disk-by/label/NIXOS";
      efiDisk = "/dev/nvme0n1p1";
    };

    desktop = {
      wm = "Hyprland";
      autologin = true;
      enableHomeManager = true;
      gaming = true;
    };
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];
}
