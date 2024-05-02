{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.boot;
in
{
  options.chr.system.boot = with types; {
    enable = mkBoolOpt (!config.chr.isMicroVM) "Whether or not to enable booting.";
    efi = mkBoolOpt false "Whether or not to enable efi booting.";
    bootloader = mkOption {
      type = types.enum [
        "none"
        "grub"
        "systemd-boot"
      ];
      default = "systemd-boot";
    };
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = cfg.efi;
      systemd-boot = mkIf (config.chr.system.boot.bootloader == "systemd-boot") {
        enable = mkDefault true;
        configurationLimit = 10;
        consoleMode = "max";
        editor = false;
      };
    };

    hardware.enableRedistributableFirmware = true;

    boot.kernelPackages = mkDefault pkgs.linuxPackages_xanmod_latest;

    boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    boot.initrd = {
      systemd.enable = true;
    };
  };
}
