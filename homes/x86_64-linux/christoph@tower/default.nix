{ lib, pkgs, config, osConfig ? { }, format ? "unknown", ... }:

with lib.chr;
{
  chr = {
    user = {
      enable = true;
    };
  };
}