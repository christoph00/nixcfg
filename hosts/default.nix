{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    nixosConfigurations = {
      air13 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.laptop
          ./air13.nix
        ];
      };
    };
  };
}
