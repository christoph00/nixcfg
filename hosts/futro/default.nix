{
  pkgs,
  lib,
  ...
}: {
  nos = {
    type = "server";
    hw = {
      cpu = "amd";
      gpu = "amd";
    };
    fs = {
      btrfs = true;
      persist = false;
    };
    network.domain = "r505.de";
    services = {
      smart-home = true;
      nas.enable = true;
    };
  };
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

  fileSystems."/mnt/userdata" = {
    device = "/dev/disk/by-uuid/1cf7a829-5a31-4d01-aa94-e142826a1ed3";
    options = ["subvol=@userdata" "discard=async" "compress-force=zstd" "nofail"];
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

  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.amd.updateMicrocode = true;
}
