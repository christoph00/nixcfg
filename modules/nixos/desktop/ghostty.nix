{
  config,
  lib,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  up = perSystem.nixpkgs-unstable;
in
{
  config = mkIf config.desktop.enable {
    hjem.users.christoph.rum.programs.ghostty = {
      enable = true;
      package = up.ghostty;
    };
  };
}
