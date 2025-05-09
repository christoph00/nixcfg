{
  flake,
  ...
}:
let
  inherit (flake.lib) mkBoolOpt;
in
{

  imports = [ ./podman.nix ];

  options.virt = {
    podman = mkBoolOpt false;
    microvm = mkBoolOpt false;
    microGuest = mkBoolOpt false;
    container = mkBoolOpt false;
  };
}
