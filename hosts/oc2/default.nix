{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "xfs";
  };
  swapDevices = [{device = "/dev/sda2";}];

  networking.hostName = "oc2";
  networking.interfaces.ens3.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
