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
          ./starship.nix
          ./terminal.nix
        ];
      };
    };
  };
}
