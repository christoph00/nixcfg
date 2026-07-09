{ pkgs, inputs }:
pkgs.mkShell {
  packages = [
    pkgs.nixd
    pkgs.nixfmt
    pkgs.nixfmt-tree
    pkgs.ragenix
    inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
  ];
  # env = { };

  # shellHook = ''   '';
}
