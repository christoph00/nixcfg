{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "sr_mod" "virtio_blk"];

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      efiSupport = false;
      devices = ["/dev/vda"];
    };
  };

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };
  fileSystems."/nix/persist".neededForBoot = true;

  networking.hostName = "star";
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.enp0s3.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  services.sabnzbd = {
    enable = true;
    group = "media";
  };
  users.users.sabnzbd = {
    #isNormalUser = true;
    #isSystemUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtkH/Ux40Ks3hJToweMP+YhCgBrPZNH/4POZZuGCqmH star-sab"
    ];
  };
  # ----------  Secrets  -----------------------------------------
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
  age.secrets.rclone-conf = {
    file = ../../secrets/rclone.conf;
    path = "/home/christoph/.config/rclone/rclone.conf";
    owner = "christoph";
    mode = "660";
  };
}
