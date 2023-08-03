# libs from https://github.com/NotAShelf/nyx
{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  system = import ./system.nix {inherit lib inputs nixpkgs;};
in
  nixpkgs.lib.extend (_: _: system)
