{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  configTxt = pkgs.writeText "config.txt" ''
    [pi3]
    kernel=u-boot-rpi3.bin

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';

  raspberrypi-update-3b = pkgs.writeShellScriptBin "rpi-update-3b" ''
    mount /dev/disk/by-label/FIRMWARE
    (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf /mnt)

    # Add the config
    cp ${configTxt} /mnt/config.txt

    # Add pi3 specific files
    cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin /mnt/u-boot-rpi3.bin
    umount /dev/disk/by-label/FIRMWARE
  '';
in
{

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

  boot = {
    kernelParams = [
      "cma=32M"
      "console=ttyS0,115200n8"
      "console=tty0"
    ];

    kernelPackages = pkgs.linuxPackages_rpi3;

    cleanTmpDir = true;

    loader = {
      raspberryPi.version = 3;

      generic-extlinux-compatible.enable = true;

      grub.enable = false;
    };
  };

  environment.systemPackages = [

    raspberrypi-update-3b
  ];
  hardware.enableRedistributableFirmware = mkDefault true;

  system.activationScripts.raspberrypi-update = "${raspberrypi-update-3b}/bin/rpi-update-3b";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "f2fs";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  networking.interfaces.eth0.useDHCP = mkDefault true;

}
