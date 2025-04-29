{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./openvz.nix
  ];

  networking.hostName = "star";

  internal.type = "vm";
  internal.system.fs.enable = false;
  internal.system.fs.device = "/dev/ploop62670";
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.swapSize = "1G";
  internal.system.state.enable = false;
  internal.system.boot.enable = false;

  systemd.network.networks.venet0 = {
    name = "venet0";
    address = [ "77.223.215.81/24" ];
    networkConfig = {
      DHCP = "no";
      DefaultRouteOnDevice = "yes";
      ConfigureWithoutCarrier = "yes";
    };
  };

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];

  system.stateVersion = "24.11";
}
