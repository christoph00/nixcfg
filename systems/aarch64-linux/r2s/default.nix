{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  namespace,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "r2s";

  internal.type = "server";
  internal.system.boot.enable = false;
  internal.system.fs.enable = false;
  internal.system.state.enable = false;

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.systemd.tpm2.enable = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  security.rtkit.enable = true;

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";
}
