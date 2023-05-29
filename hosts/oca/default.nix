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

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };
  fileSystems."/nix/persist".neededForBoot = true;

  swapDevices = [];

  networking.hostName = "oca";

  networking.interfaces.eth0.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  #environment.systemPackages = [];

  environment.persistence."/nix/persist" = {
    users.christoph = {
      directories = [
        "Downloads"
        "Documents"
        "Code"
        {
          directory = ".ssh";
          mode = "0700";
        }
        ".local/share/direnv"
      ];
    };
  };

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
  age.secrets.rclone-conf = {
    file = ../../secrets/rclone.conf;
    path = "/home/christoph/.config/rclone/rclone.conf";
    owner = "christoph";
    mode = "660";
  };
}
