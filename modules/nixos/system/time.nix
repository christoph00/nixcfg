{ lib, ... }:
let
  inherit (lib) mkDefault;
  # inherit (flake.lib) mkBoolOpt;
in
{
  config = {
    time.timeZone = mkDefault "Europe/Berlin";
  };
}
