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
    type = "desktop";
  };
}
