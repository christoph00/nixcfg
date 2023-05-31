{self, ...}: {
  flake = {
    homeManagerModules.default.imports = [./home-manager];
    nixosModules.autologin-graphical-session.imports = [./nixos/autologin-graphical-session.nix];
    nixosModules.tailscale-tls.imports = [./nixos/tailscale-tls.nix];
    nixosModules.pia-vpn.imports = [./nixos/pia-vpn.nix];
  };
}
