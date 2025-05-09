{ pkgs }:
pkgs.mkShell {
  packages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.ragenix
  ];

  # env = { };

  # shellHook = ''   '';
}
