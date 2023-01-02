{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.boot;
in {
  options.conf.boot = {
    enable = mkEnableOption "Bootloader Config";
  };

  config = mkIf cfg.enable {
    boot.initrd.systemd.enable = lib.mkDefault true;
    boot.loader = {
      timeout = 3;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
      };
      #efi.canTouchEfiVariables = true;
    };
  };
}
