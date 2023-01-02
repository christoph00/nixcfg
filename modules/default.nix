{
  flake.nixosModules = {
    conf = {imports = [./conf];};
  };
}
