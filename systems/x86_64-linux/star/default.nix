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
    addresses = [
      {
        addressConfig = {
          Address = "127.0.0.1/32";
          Scope = "host";
        };
      }
      {
        addressConfig = {
          Address = "77.223.215.81/32";
          Broadcast = "77.223.215.81";
          Scope = "global";
        };
      }
    ];
    networkConfig = {
      DHCP = "no";
      DNSSEC = "no";
      DefaultRouteOnDevice = "yes";
      ConfigureWithoutCarrier = "yes";
    };
  };

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];

  services.resolved = {
    enable = false;
    dnssec = "false";
  };

  # Manually set resolv.conf for now
  environment.etc = {
    "resolv.conf".text = "nameserver 8.8.8.8\n";
  };

  fileSystems."/" = {
    device = "/dev/ploop48914p1";
    fsType = "ext4";
  };

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "kvm_intel"
  ];

  system.stateVersion = "24.11";
}
