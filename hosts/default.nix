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
          #self.nixosModules.home-laptop-christoph
          ./air13
        ];
      };
      tower = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.desktop
          self.nixosModules.home-desktop-christoph
          #self.nixosModules.gamestream
          #self.nixosModules.code-server
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
      oca = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.webmail
          ./oca
        ];
      };
      oc1 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          ./oc1
        ];
      };
    };
  };
}
