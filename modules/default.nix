{self, ...}: {
  flake = {
    homeManagerModules.default.imports = [./home-manager];
    nixosModules.sftpgo.imports = [./nixos/sftpgo.nix];
    nixosModules.gotosocial.imports = [./nixos/gotosocial.nix];
    nixosModules.autologin-graphical-session.imports = [./nixos/autologin-graphical-session.nix];
    nixosModules.tailscale-tls.imports = [./nixos/tailscale-tls.nix];
    nixosModules.stalwart.imports = [./nixos/stalwart.nix];
  };
}
