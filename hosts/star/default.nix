{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "sr_mod" "virtio_blk"];

  boot.loader.grub = {
    devices = ["/dev/vda"];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };

  networking.hostName = "star";
  networking.interfaces.ens3.useDHCP = true;

  powerManagement.cpuFreqGovernor = "performance";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
