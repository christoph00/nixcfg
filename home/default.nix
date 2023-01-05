{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "22.11";
        nixpkgs.overlays = builtins.attrValues self.overlays;
        nixpkgs.config.allowUnfree = true;
        imports = [
          inputs.impermanence.nixosModules.home-manager.impermanence
          inputs.nix-colors.homeManagerModule
          ./cli
        ];
      };
      desktop.imports = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
        inputs.hyprland.homeManagerModules.default
        ./desktop
        ./applications
      ];
      gaming.imports = [./gaming];
    };
  };
}
