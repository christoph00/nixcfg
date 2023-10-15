{
  pkgs,
  config,
  lib,
  channel,
  ...
}:
with lib;
with lib.chr; {
  imports = [./hardware.nix];

  chr = {
    type = "laptop";
  };
  chr.system.filesystem = {
    enable = mkDefault true;
    btrfs = mkDefault true;
    persist = mkDefault true;
    mainDisk = mkDefault "/dev/nvme0n1p3";
    efiDisk = mkDefault "/dev/nvme0n1p1";
    rootOnTmpfs = mkDefault true;
  };

  system.stateVersion = "23.11";
}
