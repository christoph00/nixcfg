{ inputs, flake, ... }:
let
  inherit (flake.lib) disabled;

in
{
  imports = [
    inputs.self.nixosModules.host
    ./openvz.nix
  ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "star";

  # sys.disk.device = "/dev/ploop62670";
  sys.disk = disabled;
  sys.state = disabled;

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

}
