{
  pkgs,
  config,
  ...
}: {
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
      }) ["etc" "var" "home"];
  };

  networking = {
    hostName = "vm-router";
  };
  microvm.interfaces = [
    {
      type = "tap";
      id = "mgt-${config.networking.hostName}";
      # since we do not have a common bridge we can use a fixed mac address for all vms
      mac = "02:00:00:01:01:01";
    }
    {
      type = "tap";
      id = "tap-internet";
      # networkd will randomly assign a mac address
      mac = "02:00:00:01:01:02";
    }
  ];

  systemd.network = {
    enable = true;
    links."05-management" = {
      matchConfig.MACAddress = "02:00:00:01:01:01";
      linkConfig.Name = "management";
    };
    networks."05-management" = {
      matchConfig.Name = "management";
      networkConfig.Address = "fe80::2/64";
    };

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
      addresses = [
        # these should not collide with any other subnets
        {addressConfig.Address = "192.168.212.1/24";}
        {addressConfig.Address = "fd4b:9650:cf30:0::/64";}
      ];
      ipv6Prefixes = [{ipv6PrefixConfig.Prefix = "fd4b:9650:cf30:0::/64";}];
    };
  };
}
