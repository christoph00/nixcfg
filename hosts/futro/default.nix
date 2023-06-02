{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod"];
  # boot.kernelParams = ["radeon.cik_support=0" "amdgpu.cik_support=1"];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/62F9-9D4F";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/55528dfb-55d3-41c7-9841-f392724839ef";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/media/data-ssd" = {
    device = "/dev/disk/by-uuid/1cf7a829-5a31-4d01-aa94-e142826a1ed3";
    options = ["subvol=@data" "discard=async" "compress-force=zstd" "nofail"];
  };

  fileSystems."/mnt/ncdata" = {
    device = "/dev/disk/by-uuid/1cf7a829-5a31-4d01-aa94-e142826a1ed3";
    options = ["subvol=@ncdata" "discard=async" "compress-force=zstd" "nofail"];
  };

  fileSystems."/media/data-hdd" = {
    device = "/dev/disk/by-uuid/1c39c565-7d6c-4924-b709-2516b50b542f";
    options = ["subvol=@data" "compress-force=zstd" "nofail"];
  };

  swapDevices = [
    {
      device = "/nix/swapfile";
      #priority = 0;
      size = 2147;
    }
  ];

  #networking.useDHCP = true;
  # networking.interfaces.enp3s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f1.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;

  networking.hostName = "futro";

  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.amd.updateMicrocode = true;

  # hardware.opengl = {
  # driSupport = true;
  # };

  services.nextcloud.home = "/mnt/ncdata";
  services.nextcloud.hostName = "cloud.r505.de";


  # ----------  Secrets  -----------------------------------------
  age.secrets.cloudflared.file = ../../secrets/futro-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
  age.secrets.agent-key = {
    file = ../../secrets/agent-key;
    owner = "hass";
    mode = "600";
  };
  age.secrets.nd-key = {
    file = ../../secrets/nd-key;
    owner = "christoph";
    mode = "600";
  };
  age.secrets.rclone-nd-conf = {
    file = ../../secrets/rclone-nd.conf;
    # owner = "christoph";
    # mode = "600";
  };
  age.secrets.rclone-conf = {
    file = ../../secrets/rclone.conf;
    path = "/home/christoph/.config/rclone/rclone.conf";
    owner = "christoph";
    mode = "660";
  };
}
