{
  config,
  pkgs,
  lib,
  ...
}:
{


  powerManagement.cpuFreqGovernor = "schedutil";

   boot = {
    kernelParams = ["cma=32M"];
    
    kernelPackages = pkgs.linuxPackages_rpi3;

    cleanTmpDir = true;
    
    loader = {
      raspberryPi.version = 3;
      raspberryPi.enable = true;

    generic-extlinux-compatible.enable = true;

    grub.enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "fs2s";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];



 
}
