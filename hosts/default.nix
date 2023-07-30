{
  self,
  lib,
  withSystem,
  ...
}: let
  inputs = self.inputs;
  inherit (lib) concatLists mkNixosIso mkNixosSystem;

  sharedArgs = {inherit inputs self lib;};
in {
  tower = mkNixosSystem {
    inherit withSystem;
    hostname = "tower";
    system = "x86_64-linux";
    specialArgs = sharedArgs;
  };
}
