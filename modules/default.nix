{self, ...}: {
  flake = {
    homeManagerModules.default.imports = [./home-manager];
    nixosModules.sftpgo.imports = [./nixos/sftpgo.nix];
  };
}
