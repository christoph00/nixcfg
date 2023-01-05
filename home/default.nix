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
        imports = [
          inputs.impermanence.nixosModules.home-manager.impermanence
          inputs.nix-colors.homeManagerModule
          inputs.emanote.homeManagerModule
          ./cli
          ../modules/home-manager
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
