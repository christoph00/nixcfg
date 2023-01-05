{self, ...}: {
  flake = {
    homeModules.custom.imports = [./home-manager];
  };
}
