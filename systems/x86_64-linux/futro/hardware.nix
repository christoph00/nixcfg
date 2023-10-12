{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: let
  inherit (inputs) nixos-hardware;
in {
  imports = with nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    common-cpu-amd
    common-gpu-amd
    common-pc
    common-pc-ssd
  ];

  swapDevices = [{device = "/dev/nvme0n1p2";}];

  services.fstrim.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  boot.initrd = {
    availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
  };
}
