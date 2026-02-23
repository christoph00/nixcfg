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

  networking.hostName = "one";

  sys.disk.device = "/dev/vda";
  sys.disk.forceDevice = true;
  host.vm = true;
  host.minimal = true;
  hw.gpu = "vm";
  hw.cpu = "intel";

  # services.stalwart-mail = enabled;
  services.karakeep = enabled;

  cnt.stalwart = enabled;

  svc.webserver = enabled // {
    services = {
      mail = {
        enable = true;
        subdomain = "mail";
        port = 8088;
      };
      jmap = {
        enable = true;
        subdomain = "jmap";
        port = 8087;
      };
      keep = {
        enable = true;
        subdomain = "keep";
        inherit (config.services.karakeep) port;
      };
    };
  };

  # services.openssh.openFirewall = false;

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

  # Network configuration

  # network.enableDHCPLAN = false;

  # networking.interfaces.ens3.ipv4.addresses = [
  #   {
  #     address = "185.228.136.218";
  #     prefixLength = 22;
  #   }
  # ];
  # networking.interfaces.ens3.ipv6.addresses = [
  #   {
  #     address = "2a03:4000:23:cac::2025";
  #     prefixLength = 64;
  #   }
  # ];
  # networking.defaultGateway = "185.228.136.1";
  # networking.defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

  # Public IP configuration
  network.publicIP = "185.228.136.218";

  # WireGuard configuration
  network.wireguard = {
    enable = true;
    ip = "10.100.100.50";
    publicKey = "583eAPBGntxyvah8K1VfCPInv3F1iZ6vfO/KEQlYEkE=";
    homeRoute = true;
  };

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}
