{ pkgs, inputs }:
pkgs.mkShell {
  packages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.ragenix
    inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
  ];
  # env = { };

  # shellHook = ''   '';
}
