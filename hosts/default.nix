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
          self.nixosModules.home-laptop-christoph
          ./air13
        ];
      };
      tower = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.desktop
          self.nixosModules.home-desktop-christoph
          self.nixosModules.vm-win11
          ./tower
        ];
      };
      futro = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.smart-home
          self.nixosModules.home-server
          ./futro
        ];
      };
    };
  };
}
