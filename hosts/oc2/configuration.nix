{ inputs, pkgs, ... }:
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "oc2";

  sys.state.enable = false;
  sys.disk.type = "xfs";

  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;

  host.vm = true;

  services.openssh.openFirewall = false;

  # -- n8n
  services.n8n.enable = true;
  services.n8n.webhookUrl = "https://n8n.r505.de";
  environment.systemPackages = [ pkgs.uv ];
  programs.npm.enable = true;

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
