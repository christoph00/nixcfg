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
    type = "server";
    system.filesystem = {
      enable = mkDefault true;
      btrfs = mkDefault true;
      persist = mkDefault true;
      mainDisk = mkDefault "/dev/nvme0n1p3";
      efiDisk = mkDefault "/dev/nvme0n1p1";
      rootOnTmpfs = mkDefault true;
    };
    services = {
      nas.enable = true;
      home-assistant.enable = true;
    };
  };
}
