{
  lib,
  config,
  ...
}: {
  config = {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = lib.mkIf (config.nos.bootloader == "systemd-boot") {
        enable = lib.mkDefault true;
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
