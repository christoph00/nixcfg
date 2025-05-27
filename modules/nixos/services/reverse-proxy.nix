{
  lib,
  flake,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
in
{
  options.svc.reverse-proxy = {
    enable = mkBoolOpt false;

  };
}
