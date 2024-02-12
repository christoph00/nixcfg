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

    interfaces = [
      {
        type = "macvtap";
        id = config.networking.hostName;
        mac = "17-0f-fd-15-9b-a0";
        macvtap = {
          link = "ts0";
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
    hostName = "vm-router";
  };
}
