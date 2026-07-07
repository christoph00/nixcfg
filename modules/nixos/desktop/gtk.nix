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
    home.rum.misc.gtk = {
      enable = true;
      packages = [
        up.bibata-cursors
      ];
    };
  };
}
