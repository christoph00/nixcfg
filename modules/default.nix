{self, ...}: {
  flake = {
    homeManagerModules.default.imports = [./home-manager];
  };
}
