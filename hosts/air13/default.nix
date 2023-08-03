{pkgs, ...}: {
  nos = {
    type = "laptop";
    hw = {
      cpu = "intel";
      gpu = "intel";
    };
    fs = {
      btrfs = true;
      persist = true;
      mainDisk = "/dev/nvme0n1p3";
      efiDisk = "/dev/nvme0n1p1";
    };
    enableHomeManager = true;

    desktop = {
      wm = "Hyprland";
      autologin = true;
      gaming = true;
    };
  };

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
}
