{
  config,
  lib,
  pkgs,
  ...
}: {
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "sr_mod" "virtio_blk" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1aa61c31-3ec6-4145-8ae8-2ed286cedf1b";
    fsType = "btrfs";
    options = ["subvol=@root"];
  };
1
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B74C-70ED";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1aa61c31-3ec6-4145-8ae8-2ed286cedf1b";
    fsType = "btrfs";
    options = ["subvol=@home" "noatime" "compress-force=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1aa61c31-3ec6-4145-8ae8-2ed286cedf1b";
    fsType = "btrfs";
    options = ["subvol=@nix" "noatime" "compress-force=zstd"];
  };

  fileSystems."/nix/persist" = {
    device = "/dev/disk/by-uuid/1aa61c31-3ec6-4145-8ae8-2ed286cedf1b";
    fsType = "btrfs";
    options = ["subvol=@persist" "noatime" "compress-force=zstd"];
  };

  swapDevices = [];

  networking.hostName = "star";
  networking.interfaces.ens3.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  #age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  #age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
