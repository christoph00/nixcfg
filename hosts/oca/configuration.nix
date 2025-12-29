{
  inputs,
  lib,
  flake,
  config,
  ...
}:
let
  inherit (flake.lib) create-caddy-proxy enabled;
in
{
  imports = [ inputs.self.nixosModules.host ];

  networking.hostName = "oca";
  sys.disk.device = "/dev/sda";
  sys.disk.forceDevice = true;

  hw.cpu = "other";

  # virt.podman = true;

  host.vm = true;
  shell.devtools = enabled;

  # svc.proxy = enabled;
  # svc.mcp-proxy = enabled;
  # svc.media = enabled;
  # svc.neovim-server = enabled;

  svc.code-tunnel = enabled;

  # services.searx = enabled;
  services.n8n = enabled;
  # services.audiobookshelf = enabled;
  # services.rss-bridge = enabled;
  # services.pinchflat = enabled;
  services.open-webui = enabled;
  svc.litellm = enabled;
  # services.sabnzbd = enabled;
  # services.actual = enabled;

  services.altmount = enabled;

  svc.webserver = enabled // {
    services = {
      n8n = {
        enable = true;
        subdomain = "n8n";
        port = 5678;
      };
      open-webui = {
        enable = true;
        subdomain = "ai";
        port = config.services.open-webui.port;
      };
      #   litellm = {
      #     enable = true;
      #     subdomain = "llm";
      #     port = config.services.litellm.port;
      # };
    };
  };

  networking.timeServers = [ "169.254.169.254" ];

  network.publicIP = "152.70.42.43";

  # WireGuard configuration
  network.wireguard = {
    enable = true;
    ip = "10.100.100.21";
    publicKey = "X7eH5ByMRdlSztO6qlAkJSXx00fZ+TPYXXHxpLYwbHo=";
    homeRoute = true;
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

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";

  nixpkgs.hostPlatform = "aarch64-linux";
}
