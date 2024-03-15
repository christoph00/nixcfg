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
    mem = 1024;
    vcpu = 2;

    interfaces = [
      {
        type = "macvtap";
        id = "vm-${config.networking.hostName}";
        mac = "02:00:00:01:01:10";
        macvtap = {
          link = "enp0s20f0u4c2";
          mode = "bridge";
        };
      }
    ];

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
    hostName = "vm-smarthome";
  };

  chr.services = {
    # smart-home = true;
  };
}
