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
          self.nixosModules.gamestream
          self.nixosModules.gaming
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
          self.nixosModules.reverse-proxy-server
          ./futro
        ];
      };
      r2s1 = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.router
          ./r2s1
        ];
      };
      oca = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.webmail
          self.nixosModules.caldav
          self.nixosModules.remote-server
          ./oca
        ];
      };
      oc1 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.reverse-proxy-server
          ./oc1
        ];
      };
      oc2 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.reverse-proxy-server
          ./oc2
        ];
      };
    };
  };
}
