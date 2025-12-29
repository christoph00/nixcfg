{
  inputs,
  flake,
  config,
  ...
}:
let
  inherit (flake.lib) create-proxy mkSecret;

  ip_oca = flake.nixosConfigurations.oca.config.network.netbird.ip;
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
  host.minimal = true;
  hw.gpu = "vm";
  hw.cpu = "amd";

  svc.webserver.enable = true;

  services.openssh.openFirewall = false;

  services.headscale.enable = true;

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

  # WireGuard configuration
  network.wireguard = {
    enable = true;
    ip = "10.100.100.22";
    publicKey = "imcTI5Zu3QiHS4MgvaDFYEvmNJYrMRstP9GWS9sBVyg=";
  };

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
