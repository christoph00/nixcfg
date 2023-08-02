# libs from https://github.com/NotAShelf/nyx
{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  system = import ./builders.nix {inherit lib inputs nixpkgs;};
  modules = import ./builders.nix {inherit lib;};
in
  nixpkgs.lib.extend (_: _: system // modules)
