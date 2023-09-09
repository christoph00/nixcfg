{
  pkgs,
  lib,
  ...
}: {
  nos = {
    type = "server";
    hw = {
      cpu = "arm";
    };
    fs = {
      btrfs = true;
      persist = true;
      rootOnTmpfs = true;
      mainDisk = "/dev/vda";
    };
    network.domain = "r505.de";
  };
  networking.interfaces.eth0.useDHCP = true;

   boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "usbhid"];
  boot.kernelParams = ["net.ifnames=0"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };


  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}
