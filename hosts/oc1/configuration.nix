{ inputs, flake, ... }:
let
  inherit (flake.lib) create-proxy;
in
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "oc1";

  sys.state.enable = false;
  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;
  sys.disk.type = "xfs";
  host.vm = true;
  hw.gpu = "vm";
  hw.cpu = "amd";

  svc.webserver.enable = true;

  services.openssh.openFirewall = false;

  services.nginx.virtualHosts."ha.r505.de" = create-proxy {
    host = "100.77.199.49";
    port = 8123;
    proxy-web-sockets = true;
  };
  services.nginx.virtualHosts."n8n.r505.de" = create-proxy {
    host = "100.77.109.190";
    port = 5678;
    proxy-web-sockets = true;
  };
  services.nginx.virtualHosts."search.r505.de" = create-proxy {
    host = "100.77.155.15";
    port = 1033;
    proxy-web-sockets = true;
    extraConfig.locations."/".extraConfig = ''
      allow 130.162.232.230
      deny all;
    '';
  };

  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    # "console=ttyAMA0,115200"
  ];

  networking.timeServers = [ "169.254.169.254" ];

  boot.initrd = {
    availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
      "vmw_pvscsi"
      "virtio_net"
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"

    ];
    kernelModules = [
      "nvme"
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
  };
}
