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
    # ./microvm
  ];

  options.virt = {
    podman = mkBoolOpt false;
    microGuest = mkBoolOpt false;
  };
}
