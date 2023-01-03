{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    nixosModules = {
      home-christoph = self.lib.mkHomeModule [self.homeModules.desktop] "christoph";

      home-manager.imports = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
            flake = {inherit config;};
          };
        }
      ];
      default = {
        imports = [
          inputs.agenix.nixosModules.age
          inputs.vscode-server.nixosModule
          inputs.impermanence.nixosModules.impermanence

          inputs.srvos.nixosModules.common
          inputs.srvos.nixosModules.mixins-systemd-boot

          ./common.nix
        ];
        nixpkgs.overlays = builtins.attrValues self.overlays;
        nixpkgs.config.allowUnfree = true;
      };
      desktop.imports = [
        inputs.home-manager.nixosModule
        inputs.hyprland.nixosModules.default
        self.nixosModules.default
        self.nixosModules.home-manager
        inputs.srvos.nixosModules.desktop
        self.nixosModules.home-christoph
        ./desktop.nix
        ./greetd.nix
      ];
      laptop.imports = [
        self.nixosModules.desktop
        ./laptop.nix
      ];
      headless.imports = [
        inputs.srvos.nixosmodules.server
      ];
      server.imports = [
        self.nixosModules.headless
      ];
    };
  };
}
