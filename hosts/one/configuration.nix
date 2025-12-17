{
  inputs,
  flake,
  config,
  ...
}:
let
  inherit (flake.lib) create-proxy mkSecret;

in
{
  imports = [ inputs.self.nixosModules.host ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "one";

  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;
  host.vm = true;
  host.minimal = true;
  hw.gpu = "vm";
  hw.cpu = "intel";

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
    ip = "10.100.100.50";
    publicKey = "=";
  };


}
