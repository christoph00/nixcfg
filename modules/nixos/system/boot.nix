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
        configurationLimit = 6;
        consoleMode = "max";
        editor = false;
      };
    };

    initrd = {
      systemd.enable = true;
    };
  };
}
