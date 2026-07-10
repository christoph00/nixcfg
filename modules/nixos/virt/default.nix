{
  flake,
  ...
}:
let
  inherit (flake.lib) mkBoolOpt;
in
{

  imports = [
    ./podman.nix
    ./containers
  ];

  options.virt = {
    podman = mkBoolOpt false;
  };
}
