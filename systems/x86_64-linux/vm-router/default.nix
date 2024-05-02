{ pkgs, config, ... }:
{
  chr = {
    type = "microvm";
  };

  microvm = {
    hypervisor = "cloud-hypervisor";
    mem = 512;
    vcpu = 2;

    shares =
      [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "store";
          proto = "virtiofs";
          socket = "store.socket";
        }
      ]
      ++ map
        (dir: {
          source = "/var/lib/microvms/${config.networking.hostName}/${dir}";
          mountPoint = "/${dir}";
          tag = dir;
          proto = "virtiofs";
          socket = "${dir}.socket";
        })
        [
          "etc"
          "var"
          "home"
        ];
  };

  networking = {
    hostName = "vm-router";
  };
  microvm.interfaces = [
    {
      type = "tap";
      id = "tap-internet";
      # networkd will randomly assign a mac address
      mac = "02:00:00:01:01:02";
    }
  ];

  networking.firewall.allowedUDPPorts = [ 67 ]; # dhcp

  systemd.network = {
    enable = true;

    links."05-internet-bridge" = {
      matchConfig.MACAddress = "02:00:00:01:01:02";
      linkConfig.MACAddressPolicy = "random";
      linkConfig.Name = "lan";
    };
    networks."05-internet-bridge" = {
      matchConfig.Name = "lan";

      networkConfig = {
        DHCPServer = true;
        IPv6SendRA = true;
      };
      addresses = [ { addressConfig.Address = "192.168.10.1/24"; } ];
    };
  };
}
