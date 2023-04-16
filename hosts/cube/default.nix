{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod"];
  boot.kernelParams = ["radeon.cik_support=0" "amdgpu.cik_support=1"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/32f9120a-1ab8-428e-805a-e52b2ee8d9b0";
    fsType = "btrfs";
    options = ["subvol=@root" "discard=async" "compress-force=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/32f9120a-1ab8-428e-805a-e52b2ee8d9b0";
    fsType = "btrfs";
    options = ["subvol=@nix" "discard=async" "compress-force=zstd"];
  };

  fileSystems."/nix/persist" = {
    device = "/dev/disk/by-uuid/32f9120a-1ab8-428e-805a-e52b2ee8d9b0";
    fsType = "btrfs";
    options = ["subvol=@persist" "discard=async" "compress-force=zstd"];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5EE1-7092";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/sda2";}
  ];

  networking.hostName = "cube";

  systemd.network.networks = {
    lan = {
      enable = true;
      DHCP = "yes";
      matchConfig.Name = "enp1s0";
      networkConfig = {
        Description = "LAN";
        MulticastDNS = true;
        DHCP = "yes";
      };
    };
  };
  systemd.network.links = {
    wan = {
      matchConfig.Name = "enp0s18u1u3";
    };
    lan = {
      matchConfig.Name = "enp1s0";
    };
  };
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.amd.updateMicrocode = true;

  hardware.opengl = {
    driSupport = true;
  };

  # ----------  Secrets  -----------------------------------------
  age.secrets.cloudflared.file = ../../secrets/futro-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
  age.secrets.agent-key = {
    file = ../../secrets/agent-key;
    owner = "hass";
    mode = "600";
  };
}
