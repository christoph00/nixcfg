{
  config,
  pkgs,
  lib,
  ...
}:

{
  nix.package = lib.mkForce pkgs.lix;
  nix.settings = {

    experimental-features = [
      "flakes"
      "nix-command"
      "auto-allocate-uids"
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];

    extra-substituters = [
      "https://chr.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nyx.chaotic.cx/"
      "https://chaotic-nyx.cachix.org"
      "https://cache.garnix.io"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
  };

}
