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
      btrfs = false;
      persist = true;
      rootOnTmpfs = true;
      efiDisk = "/dev/sdb1";
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
      configurationLimit = 5;
    };
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/nix" = {
    device = "/dev/sdb3";
    fsType = "ext4";
    neededForBoot = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}