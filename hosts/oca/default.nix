{
  config,
  lib,
  pkgs,
  ...
}: {
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

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0C57-60FD";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8521cf96-09fd-43f8-a1e7-82b853ac0320";
    fsType = "ext4";
  };

  swapDevices = [];

  networking.hostName = "oca";

  networking.interfaces.eth0.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
