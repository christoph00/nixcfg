{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "ok";
  internal = {
    type = "vm";
    system = {
      fs.device = "/dev/sda";
      fs.tmpRoot = true;
      boot.encryptedRoot = false;
    };
  };


  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "nvme"
  ];

  system.stateVersion = "24.05";
}
