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
          ./cli
        ];
      };
      desktop.imports = [
        self.homeModules.common
        ./desktop
        ./applications
      ];
    };
  };
}
