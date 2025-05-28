{
  config,
  options,
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config.home = mkIf config.desktop.enable {
    rum.programs.ghostty = {
      enable = true;
    };
  };
}
