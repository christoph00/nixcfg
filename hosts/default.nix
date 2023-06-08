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
          # self.nixosModules.gamestream
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
          #self.nixosModules.reverse-proxy-server
          self.nixosModules.webdav-server
          self.nixosModules.media-server
          #self.nixosModules.nextcloud
          self.nixosModules.nzb
          ./futro
        ];
      };
      star = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.home-headless-christoph
          #self.nixosModules.nextcloud
          self.nixosModules.nzb
          ./star
        ];
      };
      cube = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server

          # self.nixosModules.router
          ./cube
        ];
      };
      # r2s1 = inputs.nixpkgs.lib.nixosSystem {
      #   system = "aarch64-linux";
      #   modules = [
      #     self.nixosModules.sdImage
      #     self.nixosModules.server
      #     # self.nixosModules.router
      #     ./r2s1
      #   ];
      # };
      # sd-r2s1 = self.nixosConfigurations.r2s1.config.system.build.sdImage;

      oca = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          self.nixosModules.home-headless-christoph

          self.nixosModules.remote-server
          self.nixosModules.webdav-server
          ./oca
        ];
      };
      oc1 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          #self.nixosModules.reverse-proxy-server
          # self.nixosModules.mailserver
          ./oc1
        ];
      };
      oc2 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.server
          self.nixosModules.virtual
          #self.nixosModules.reverse-proxy-server
          #  self.nixosModules.mailserver
          ./oc2
        ];
      };
    };
    # images.r2s1 = self.nixosConfigurations.r2s1.config.system.build.sdImage;
  };
}
