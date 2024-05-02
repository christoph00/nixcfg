{ pkgs, ... }:

{
      packages = [ 
    pkgs.git 
    pkgs.jq
    pkgs.libffi
    pkgs.zlib
    pkgs.alejandra
    pkgs.nixfmt-rfc-style
  ];
    devcontainer.enable = true;
}