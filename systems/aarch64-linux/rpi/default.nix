{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
{
  imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "rpi";

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
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  raspberry-pi-nix = {
    board = "bcm2711";
    kernel-version = "v6_10_12";
    libcamera-overlay.enable = false;
  };
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          options = {
            arm_64bit = {
              enable = true;
              value = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = { };
            };
          };
        };
      };
    };
  };
  security.rtkit.enable = true;

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";
}
