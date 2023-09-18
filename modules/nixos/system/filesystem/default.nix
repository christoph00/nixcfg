{ options, config, pkgs, lib, ... }:

with lib;
with lib.chr;
let cfg = config.chr.system.filesystem;
in
{
  options.chr.system.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to configure filesystems.";
       persist = mkEnableOption "rollback root";
      rootOnTmpfs = mkEnableOption "mount root on tmpfs";
      stateDir = mkOption {
        type = types.str;
        default = "/nix/persist";
      };
      btrfs = mkEnableOption "btrfs layout";
      mainDisk = mkOption {
        type = types.str;
        default = "/dev/sda2";
      };
      efiDisk = mkOption {
        type = types.str;
        default = "/dev/disk/by-label/UEFI";
      };
      swapDevice = mkOption {
        type = types.str;
        default = "/dev/sda3";
      };
  };

  config = mkIf cfg.enable { 



   };
}