{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.boot;
in {
  options.chr.system.boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable booting.";
    bootloader = mkOpt types.enum ["none" "grub" "systemd-boot"] "systemd-boot" "Bootloader to use";
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = mkIf (config.chr.system.boot.bootloader == "systemd-boot") {
        enable = mkDefault true;
        configurationLimit = 5;
        consoleMode = "max";
        editor = false;
      };
    };

    boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];

    boot.initrd = {
      systemd.enable = true;
    };
  };
}
