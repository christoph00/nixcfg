{
  inputs,
  flake,
  config,
  lib,
  ...
}:
let
  inherit (flake.lib) enabled;
in
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "xcc";

  sys.boot.mode = "bios";
  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;
  sys.state.enable = false;
  host.vm = true;
  host.minimal = true;
  host.bootstrap = true;
  hw.gpu = "vm";
  hw.cpu = "amd";

  network.enableDHCPLAN = true;



  boot.kernelParams = [
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    # "console=ttyAMA0,115200"
  ];


  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}
