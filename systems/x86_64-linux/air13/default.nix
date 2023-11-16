{
  pkgs,
  config,
  lib,
  channel,
  inputs,
  ...
}:
with lib;
with lib.chr; {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];

  boot.kernelModules = ["kvm-intel" "acpi_call" "bbswitch" "iwlwifi" "i915"];
  boot.blacklistedKernelModules = ["nouveau" "nvidia" "iwlwifi"];
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "udev.log-priority=3"
    "vt.global_cursor_default=0"
  ];
  #boot.resumeDevice = "/dev/disk/by-label/air13";

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  chr = {
    type = "server";
  };
  chr.system.filesystem = {
    enable = true;
    btrfs = true;
    disko = false;
    persist = true;
    mainDisk = "/dev/nvme0n1p3";
    efiDisk = "/dev/nvme0n1p1";
    rootOnTmpfs = true;
  };

  services.logind.lidSwitch = "ignore";
  services.upower.ignoreLid = true;

  networking.useNetworkd = true;
  systemd.network.networks."40-wired" = {
    matchConfig = {Name = lib.mkForce "enp* eth*";};
    DHCP = "yes";
    networkConfig = {
      IPv6PrivacyExtensions = "yes";
    };
  };

  system.stateVersion = "23.11";
}
