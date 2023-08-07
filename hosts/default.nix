{
  self,
  lib,
  withSystem,
  ...
}: let
  inputs = self.inputs;
  inherit (lib) concatLists mkNixosSystem;

  sharedArgs = {inherit inputs self lib;};
in {
  tower = mkNixosSystem {
    inherit withSystem;
    hostname = "tower";
    system = "x86_64-linux";
    specialArgs = sharedArgs;
  };
  air13 = mkNixosSystem {
    inherit withSystem;
    hostname = "air13";
    system = "x86_64-linux";
    specialArgs = sharedArgs;
  };
  futro = mkNixosSystem {
    inherit withSystem;
    hostname = "futro";
    system = "x86_64-linux";
    specialArgs = sharedArgs;
  };
}
