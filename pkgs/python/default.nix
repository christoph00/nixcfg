{
  pkgs,
  lib,
}: python-final: python-prev: {
  wyoming = python-final.callPackage ./wyoming.nix {};
}
