{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    nixosModules = {
      christoph = self.lib.mkHome [] "christoph";

      home-manager.imports = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
            flake = {inherit config;};
          };
        }
      ];
      default.imports = [
        inputs.base16.nixosModule
        inputs.home-manager.nixosModule
        inputs.agenix.nixosModules.age
        inputs.vscode-server.nixosModule
        inputs.hyprland.nixosModules.default
        inputs.impermanence.nixosModules.impermanence

        self.nixosModules.home-manager
        self.nixosModules.christoph
      ];
    };
  };
}
