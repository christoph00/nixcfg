{
  self,
  inputs,
  config,
  modulesPath,
  ...
}: {
  flake = {
    nixosModules = {
      custom.imports = [
        ./nixos
      ];
    };
    homeManagerModules = {
      custom.imports = [./home-manager];
    };
  };
}
