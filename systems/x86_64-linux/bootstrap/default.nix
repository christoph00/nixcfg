{

  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "bootstrap";

  internal.type = "bootstrap";

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
  ];

  system.stateVersion = "24.05";
}
