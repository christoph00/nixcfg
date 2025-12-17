{
  inputs,
  flake,
  config,
  lib,
  ...
}:
let
  inherit (flake.lib) create-proxy mkSecret;

in
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "one";


  host.bootstrap = true;

  sys.disk.device = "/dev/vda";
  sys.disk.forceDevice = true;
  host.vm = true;
  host.minimal = true;
  hw.gpu = "vm";
  hw.cpu = "intel";

  svc.webserver.enable = true;

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

  network.enableDHCPLAN = false;

  networking.interfaces.ens3.ipv4.addresses = [
    {
      address = "185.228.136.218";
      prefixLength = 22;
    }
  ];
  networking.interfaces.ens3.ipv6.addresses = [
    {
      address = "2a03:4000:23:cac::2025";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "185.228.136.1";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

  # Public IP configuration
  network.publicIP = "185.228.136.218";

  # WireGuard configuration
  network.wireguard = {
    enable = false;
    ip = "10.100.100.50";
    publicKey = "uMOJYI5t42gnSUhlYaF1SfsLxD5PZnMnRTfAhn1cinA=";
  };



  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}
