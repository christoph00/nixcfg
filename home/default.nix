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
          ./cli
        ];
      };
      desktop.imports = [
        inputs.hyprland.homeManagerModules.default
        ./desktop
        ./applications
      ];
      gaming.imports = [ ./gaming ];
    };
  };
}
