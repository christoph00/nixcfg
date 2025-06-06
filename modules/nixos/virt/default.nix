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
    # ./microvm
  ];

  options.virt = {
    podman = mkBoolOpt false;
    microGuest = mkBoolOpt false;
    container = mkBoolOpt false;
  };
}
