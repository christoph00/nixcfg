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
    homeModules = {
      custom.imports = [./home-manager];
    };
  };
}
