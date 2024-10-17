{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
{
  imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi ];

  networking.hostName = "rpi";

  internal.type = "server";
  internal.system.boot.enable = false;
  internal.system.fs.enable = false;
  internal.system.state.enable = false;

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
