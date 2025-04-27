{
  lib,
  pkgs,
  config,
  ...
}:
{
  facter.reportPath = ./facter.json;

  networking.hostName = "oca";

  internal.type = "vm";
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  internal.services.office-server.enable = true;
  # internal.services.glance.enable = true;
  # internal.services.vscode-tunnel.enable = true;
  internal.services.ai.enable = true;
  internal.shell.neovim.enable = true;
  internal.shell.devtools.enable = true;
  internal.services.n8n.enable = true;
  internal.services.searx.enable = true;
  internal.services.audiobookshelf.enable = true;
  services.tinyproxy.enable = true;
  services.tinyproxy.settings.Listen = "0.0.0.0";
  networking.firewall.allowedTCPPorts = [ 8888 ];

  services.nginx.virtualHosts."ha.r505.de" = {
    useACMEHost = "r505.de";
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://${config.internal.hosts.lsrv.net.vpn}:8123";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  boot.initrd.kernelModules = [
    "ata_piix"
    "uhci_hcd"
    "nvme"
    "usbhid"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "24.05";
}
